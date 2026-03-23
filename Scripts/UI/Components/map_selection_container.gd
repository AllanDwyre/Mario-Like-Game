extends Control
class_name MapSelectionContainer

@onready var focus_group : FocusGroup
@onready var player_label : Label = %PlayerLabel
@onready var map_selection_enum : EnumButton = %MapSelectionEnum
@onready var thumbnail : TextureRect = %Thumbnail
@onready var panel : PanelContainer = %PanelContainer

signal map_selected_changed(device_id : int, map : MapData)
signal map_unselected(device_id : int)

var device_id: int
var maps : Dictionary[StringName, MapData]
var selected_map : MapData = null

func setup(device_id_ : int, maps_ : Array[MapData])-> void :
	device_id = device_id_
	
	for map in maps_:
		map_selection_enum.add_option(map.display_name)
		maps[map.display_name] = map
	
	focus_group.device_id = device_id_
	focus_group.activate(map_selection_enum)
	player_label.text = "Player %d" % device_id_
	
	thumbnail.texture = maps[map_selection_enum.get_current_value()].thumbnail
	
	map_selection_enum.value_changed.connect(_on_map_selection_enum_value_changed)

func _on_map_selection_enum_value_changed(_index: int, value: String):
	var _new_map = maps[value]
	thumbnail.texture = _new_map.thumbnail

func _input(event: InputEvent) -> void:
	if not focus_group.belongs_to_player(event):
		return
	
	if event.is_action_pressed("ui_accept"):
		if selected_map:
			map_selection_enum.enable = true
			selected_map = null
			map_unselected.emit(device_id)
			_update_visual()
		else:
			map_selection_enum.enable = false
			selected_map = maps[map_selection_enum.get_current_value()]
			map_selected_changed.emit(device_id, selected_map)
			_update_visual()
	

func _update_visual():
	# Add or remove border of the panel
	pass
	
	
