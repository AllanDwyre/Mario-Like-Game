extends EnemyBase

@onready var reset_state_timer: Timer = $ResetShapeTimer
@onready var anim : AnimatedSprite2D = $AnimatedSprite2D
const STOMPED_SOUND = preload("res://Arts/Audios/SFX/stomp.wav")

var walk_speed : float
@export var shell_speed : float = 80.0 

func _ready() -> void:
	super()
	walk_speed = speed
	anim.play("walk")
	reset_state_timer.timeout.connect(_revive)

func _change_direction() -> void:
	super()
	anim.flip_h = direction > 0

func _revive():
	speed = walk_speed
	stunned = false
	set_collision_mask_value(3, true)
	if direction == 0.0:
		direction = 1
		_change_direction()
	anim.play("walk")
	
func take_damage(from : Node2D):
	speed = shell_speed
	anim.play("shell")
	reset_state_timer.start()
	direction = 0.0
	# if it was it when stunned, we want the koopa to move
	if stunned:
		direction = sign(global_position.x - from.global_position.x)
		set_collision_mask_value(3, false)
	else :
		SoundManager.play_sound(STOMPED_SOUND)
		stunned = true

func kill():
	direction = 0.0
	anim.play("shell")
	
	# TODO kill animation
	
	await get_tree().create_timer(.6).timeout
	queue_free()

	

func _give_damage(body : Node2D, isPlayer : bool = true):
	# Si it another enemy while stunned, it will kill the enemy
	if not isPlayer and stunned and direction != 0.0:
		body.kill()
		return
	
	# On rajoute la condition que la tortue est en mouvement pour donner les damages
	if direction != 0.0:
		body.take_damage(self)
	else :
		# Sinon on considere ça comme si c'est le joueur qui hit la tortue
		take_damage(body)
