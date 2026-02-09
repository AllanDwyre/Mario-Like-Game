extends StaticBody2D

@onready	 var sprite : Sprite2D = $Sprite2D

const BRICK_SOUND = preload("res://Arts/Audios/SFX/hit_block.wav")
const DURATION = .3
const OFFSET = 8
# NOTE: On permet un margin
const MAX_X_DIST = 9.0

var initial_y : float
var is_animating = false


func _ready() -> void:
	initial_y = sprite.position.y  
	
func _is_under_brick(body : Mario) -> bool:
	var under = body.global_position.y > global_position.y;
	var x_distance = abs(body.global_position.x - global_position.x)
	
	return under and x_distance <= MAX_X_DIST
	
	
func interact(body : Mario):
	if not _is_under_brick(body):
		return
	
	if body.get_size() == "big":
		queue_free()
		return
		
	if is_animating:
		return
	
	SoundManager.play_sound(BRICK_SOUND)
	is_animating = true
	var tween = create_tween()
	tween.tween_property(sprite, "position:y", initial_y - OFFSET, DURATION/2.0)
	tween.tween_property(sprite, "position:y", initial_y, DURATION/2.0)
	tween.tween_callback(func() : is_animating = false)
