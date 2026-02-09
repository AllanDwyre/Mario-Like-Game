extends EnemyBase

@onready var anim : AnimatedSprite2D = $AnimatedSprite2D
const STOMPED_SOUND = preload("res://Arts/Audios/SFX/stomp.wav")

func _ready() -> void:
	super()
	anim.play("walk")

func _change_direction() -> void:
	super()
	anim.flip_h = direction > 0
	
func take_damage(_body : Node2D) -> void :
	if died:
		return
	kill()
	
func kill():
	died = true
	anim.play("death")
	SoundManager.play_sound(STOMPED_SOUND)
	
	await get_tree().create_timer(.6).timeout
	
	queue_free()
