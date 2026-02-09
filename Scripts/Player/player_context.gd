class_name PlayerContext extends RefCounted

var mario : Mario

var can_move : bool = true

var direction : float
var run_pressed : bool
var jump_pressed : bool
var has_jumped : bool
var jump_released : bool

var is_grounded : bool
var wall : Vector2 = Vector2.ZERO

var sprite : AnimatedSprite2D :
	get : return mario.sprite
	
var size : String :
	get : return mario.get_size()

func _init(player : Mario) -> void:
	mario = player
