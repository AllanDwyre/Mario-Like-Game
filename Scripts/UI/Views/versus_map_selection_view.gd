class_name VersusMapSelectionView
extends View

const MAPS: Registry = preload("res://Data/map_registry.tres")

@export var containers_parent : Control
@export var selection_container_scene : PackedScene

var lobby_setting : VersusSettings

var _maps : Array[MapData] = [] 
var _selection_containers : Array[MapSelectionContainer] = []

var _selected_maps :  Dictionary[int, MapData] = {} #Player_device_ids, MapData

func get_available_maps() -> Array[MapData]:
	var ids := MAPS.filter_by_value(&"ready_prod", true)
	# Charge uniquement celles-là
	_maps = []
	for id in ids:
		_maps.append(MAPS.load_entry(id))
	return _maps

func _ready() -> void:
	get_available_maps()

func on_show() -> void:
	_clear_containers()
	
	match lobby_setting.match_type:
		VersusSettings.ESelectionMode.Majority :
			populate_all_player()
		VersusSettings.ESelectionMode.Ban :
			populate_all_player()
		VersusSettings.ESelectionMode.Host :
			_create_map_selection_container(PlayerManager.get_host_id())
		VersusSettings.ESelectionMode.Random:
			# TODO: transform this as a warning and give a resolution
			push_error("Random is not handle by VersusMapSelectionView.")
			return
			
func populate_all_player() -> void :
	var ids = PlayerManager.get_all_player_ids()
	for id in ids:
		_create_map_selection_container(id)

#region Container creation
func _create_map_selection_container(id : int) -> void:
	var container_inst = selection_container_scene.instantiate()
	if container_inst is not MapSelectionContainer:
		return
	var container = container_inst as MapSelectionContainer
	containers_parent.add_child(container)
	_selection_containers.append(container)
	_subscribe_to_container(container)
	container.setup(id, _maps)

func _clear_containers():
	if _selection_containers.is_empty():
		return
	for i in range(_selection_containers.size()):
		var container = _selection_containers[i]
		_unsubscribe_to_container(container)
		_selection_containers.erase(container)
		container.queue_free()
	_selection_containers.clear()
	_selected_maps.clear()

func _subscribe_to_container(container : MapSelectionContainer) -> void:
	container.map_selected_changed.connect(_on_map_selected_changed)
	container.map_unselected.connect(_on_map_unselected)

func _unsubscribe_to_container(container : MapSelectionContainer) -> void:
	container.map_selected_changed.disconnect(_on_map_selected_changed)
	container.map_unselected.disconnect(_on_map_unselected)
#endregion

#region Selections Events
func _on_map_selected_changed(device_id : int, map : MapData):
	_selected_maps[device_id] = map
	_check_complete_condition()

func _on_map_unselected(device_id : int):
	_selected_maps.erase(device_id)
#endregion

#region Complete Logic
func _check_complete_condition() -> void :
	if _selected_maps.size() != _selection_containers.size():
		return
	
	match lobby_setting.match_type:
		VersusSettings.ESelectionMode.Majority :
			_handle_majority()
		VersusSettings.ESelectionMode.Ban :
			_handle_ban()
		VersusSettings.ESelectionMode.Host :
			_handle_host()
		VersusSettings.ESelectionMode.Random:
			# TODO: transform this as a warning and give a resolution
			push_error("Random is not handle by VersusMapSelectionView.")
			return

func _handle_majority() -> void:
	# Agrégation des votes
	var counts : Dictionary[MapData, int] = {}
	for map in _selected_maps.values():
		counts[map] = counts.get(map, 0) + 1
	
	# Trouve le max
	var max_votes := 0
	for count in counts.values():
		if count > max_votes:
			max_votes = count
	
	# Collecte les ex-aequo
	var top_maps : Array[MapData] = []
	for map in counts.keys():
		if counts[map] == max_votes:
			top_maps.append(map)
	
	_go_to_map(top_maps[randi() % top_maps.size()])

func _handle_ban() -> void:
	var banned := _selected_maps.values()
	
	var remaining : Array[MapData] = []
	for map in _maps:
		if map not in banned:
			remaining.append(map)
	
	if remaining.is_empty():
		push_error("_handle_ban: toutes les maps ont été bannies.")
		return
	_go_to_map(remaining[randi() % remaining.size()])

func _handle_host() -> void:
	_go_to_map(_selected_maps.values()[0])
#endregion

func _go_to_map(map : MapData) -> void:
	lobby_setting.chosen_map = map
	GameManager.start_versus_game(lobby_setting)
