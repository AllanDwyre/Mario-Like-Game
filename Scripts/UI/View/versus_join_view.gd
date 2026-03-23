class_name VersusJoinView
extends View

@export var versus_setting_scene : PackedScene

@onready var grid_container : GridContainer = %GridContainer

var _active_player_containers : Dictionary[int, PlayerJoinContainer] = {}
var _all_containers : Array[PlayerJoinContainer]

var _number_of_ready : int = 0
# --- cache view ---
var _setting_view : VersusSettingView

func on_show() -> void:
	PlayerManager.enable_joining()

func on_hide() -> void:
	PlayerManager.disable_joining()

func _ready() -> void :
	PlayerManager.reset()
	PlayerManager.player_joined.connect(_on_player_joined)
	PlayerManager.player_left.connect(_on_player_left)
	_all_containers.assign(grid_container.find_children("*", "PlayerJoinContainer", false, true))
	for container in _all_containers:
		container.ready_value_changed.connect(observe_readyness)
	_update_container()

func _exit_tree() -> void:
	PlayerManager.player_joined.disconnect(_on_player_joined)
	PlayerManager.player_left.disconnect(_on_player_left)
	for container in _all_containers:
		container.ready_value_changed.disconnect(observe_readyness)
	
func _on_player_joined(device_id: int, player_info: PlayerInfo):
	var container : PlayerJoinContainer = _get_available_container()
	if not container:
		push_warning("No PlayerJoinContainer available")
		return
	container.setup(player_info)
	_active_player_containers[device_id] = container
	_update_container()
	container.show()

func _on_player_left(device_id: int):
	# --- handle the player left ---
	var container = _active_player_containers[device_id]
	container.hide()
	container.reset()
	_active_player_containers.erase(device_id)
	# --- rename other players ---
	
	var players = _active_player_containers.values()
	for i in range(PlayerManager.get_player_count()):
		players[i].rename_player(i)
	_update_container()

func _update_container():
	var player_count = PlayerManager.get_player_count() 
	if player_count < 1:
		grid_container.columns = 1
	else:
		grid_container.columns = 2
	
	if player_count % 2 == 0 and player_count != 0: #player_count == 4 : #
		%JoinContainer.hide()
	else:
		%JoinContainer.show()
	%NumberOfPlayer.text = "%d/%d players" %[player_count, PlayerManager.MAX_PLAYERS]

func _get_available_container() -> PlayerJoinContainer:
	var availables = _all_containers.filter(func(c): return c not in _active_player_containers.values())
	if availables.is_empty():
		return null
	return availables[0]

func observe_readyness(new_value : bool) -> void :
	if new_value:
		_number_of_ready +=1
	else:
		_number_of_ready -=1
	if _number_of_ready >= _active_player_containers.size() and _number_of_ready > 1:
		go_to_setting_scene()

func go_to_setting_scene() -> void :
	if not _setting_view:
		_setting_view = versus_setting_scene.instantiate()
	ViewManager.push(_setting_view)
	
