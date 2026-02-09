extends StaticBody2D

@onready	 var sprite : Sprite2D = $Sprite2D
@export var power_up: PackedScene

var empty_box_sprite = preload("res://Arts/Textures/Items/EmptyBlock.png")
var is_empty = false

const DURATION = .3
const OFFSET = 8
var initial_y : float

func _ready() -> void:
	initial_y = sprite.position.y  
	
func interact(_body : Node2D):
	if is_empty:
		return
	is_empty = true
	
	var instance = power_up.instantiate()
	get_parent().add_child(instance)
	instance.global_position = global_position
	instance.global_position.y -= OFFSET
	
	var global = global_position.y
	
	var tween = create_tween()
	tween.tween_property(sprite, "position:y", initial_y - OFFSET, DURATION/2.0)
	tween.tween_property(sprite, "position:y", initial_y, DURATION/2.0)
	tween.parallel().tween_callback(func() : sprite.texture = empty_box_sprite)
	tween.parallel().tween_property(instance, "global_position:y", global - 16, DURATION)	
	tween.tween_callback(func() : instance.activate())
