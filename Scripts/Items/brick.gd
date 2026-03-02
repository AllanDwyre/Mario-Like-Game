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
		
		if collider is EnemyBase or collider is Player:
			collider.take_damage(self)
		elif collider.has_method("change_direction"):
			collider.change_direction()

func _is_under_brick(_player : Player, collision : KinematicCollision2D) -> bool:
	var under = collision.get_normal().y > 0.5;
	
	return under 
	
	
func interact(body : Player, collision : KinematicCollision2D):
	if not _is_under_brick(body, collision):
		return
	
	raycast.force_shapecast_update()
	if raycast.is_colliding() :
		_colliding()
#	
	if body.get_size() == "big":
		sprite.visible = false
		
		var particules =$BreakEffectParticule
		
		particules.emitting = true
		await particules.finished
		
		particules.queue_free()
		queue_free()
		return
	if is_animating:
		return
	
	SoundManager.play_sound(BRICK_SOUND)
	is_animating = true
		
	_animate(sprite, initial_y)\
			.tween_callback(func() : is_animating = false)
