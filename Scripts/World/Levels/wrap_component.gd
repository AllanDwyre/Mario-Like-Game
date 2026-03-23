extends Node
class_name WrapComponent

var _parent : Node2D
var map_info : Dictionary

func _ready() -> void:
	_parent = get_parent()
	map_info = Level.get_current_level().map_info

func wrap_position(pos : Vector2) -> Vector2:
	pos.x = wrapf(pos.x, map_info["start_pos"].x, map_info["end_pos"].x)
	return pos

func _physics_process(_d):
	_parent.global_position = wrap_position(_parent.global_position)
