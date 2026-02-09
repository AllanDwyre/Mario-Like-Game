extends StaticBody2D

@onready	 var sprite : Sprite2D = $Sprite2D
@onready	 var raycast : ShapeCast2D = $ShapeCast2D

const BRICK_SOUND = preload("res://Arts/Audios/SFX/hit_block.wav")
const STOMP_SOUND = preload("res://Arts/Audios/SFX/stomp.wav")

const DURATION = .3
const OFFSET = 8
# NOTE: On permet un margin
const MAX_X_DIST = 9.0

var initial_y : float
var is_animating = false


func _ready() -> void:
	initial_y = sprite.position.y  

func _animate(node : Node2D, initial_y_pos : float):
	var tween = create_tween()
	tween.tween_property(node, "position:y", initial_y_pos - OFFSET, DURATION/2.0)
	tween.tween_property(node, "position:y", initial_y_pos, DURATION/2.0)
	return tween

func _colliding():
	for i in range(raycast.get_collision_count()):
		var collider = raycast.get_collider(i)
		_animate(collider, collider.position.y)
		
		if collider is EnemyBase or collider is Mario:
			collider.take_damage(self)
		elif collider.has_method("change_direction"):
			collider.change_direction()

func _is_under_brick(body : Mario) -> bool:
	var under = body.global_position.y > global_position.y;
	var x_distance = abs(body.global_position.x - global_position.x)
	
	return under and x_distance <= MAX_X_DIST
	
	
func interact(body : Mario):
	if not _is_under_brick(body):
		return
	
	raycast.force_shapecast_update()
	if raycast.is_colliding() :
		_colliding()
#	
	if body.get_size() == "big":
		queue_free()
		return
		
	if is_animating:
		return
	
	SoundManager.play_sound(BRICK_SOUND)
	is_animating = true
		
	_animate(sprite, initial_y)\
			.tween_callback(func() : is_animating = false)
