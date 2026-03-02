extends EnemyBase

@onready var anim : AnimatedSprite2D = $AnimatedSprite2D
const STOMPED_SOUND = preload("res://Arts/Audios/SFX/stomp.wav")

func _ready() -> void:
	super()
	anim.play("walk")

func _change_direction() -> void:
	super()
	anim.flip_h = direction > 0

func take_damage(body : Node2D) -> void :
	if not can_take_damage(body):
		return
	if body is Player:
		body.movement.ForceJump()
	kill()

func kill():
	get_node("CollisionShape2D").set_deferred("disable", true)
	
	set_process(false)
	set_physics_process(false) # disable the movement during death
	
	anim.play("death")
	GameSignals.add_score.emit(100, global_position)
	SoundManager.play_sound(STOMPED_SOUND)
	
	await get_tree().create_timer(.6).timeout
	
	queue_free()
