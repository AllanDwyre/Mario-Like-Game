extends EnemyBase
class_name Koopa

@export var shell_speed : float = 80.0 

@onready var reset_state_timer: Timer = $ResetShapeTimer
@onready var anim : AnimatedSprite2D = $AnimatedSprite2D

const STOMPED_SOUND = preload("res://Arts/Audios/SFX/stomp.wav")
const KICK_SOUND = preload("res://Arts/Audios/SFX/kick.wav")
var walk_speed : float

enum KoopaState {
	Wondering,
	Shell,
	Moving_shell
}

var state : KoopaState = KoopaState.Wondering

func _ready() -> void:
	super()
	walk_speed = speed
	go_to_wondering_state()
	reset_state_timer.timeout.connect(go_to_wondering_state)
	

func _change_direction() -> void:
	super()
	anim.flip_h = direction > 0

func edge_collision():
	return super() and state == KoopaState.Wondering 

func _on_enemy_collision(body : Node2D):
	if state == KoopaState.Wondering:
		_change_direction()
	else :
		body.kill()

func _on_inflict_damage(to : Node2D):
	if state == KoopaState.Shell:
		return
	super(to) # to took damage !

func can_take_damage(from : Node2D):
	# peut toujour prendre des damages
	if state == KoopaState.Shell:
		return true
	return super(from)

func take_damage(from : Node2D):
	if not can_take_damage(from):
		return

	SoundManager.play_sound(STOMPED_SOUND)
	anim.play("shell")
	match state:
		KoopaState.Wondering:
			go_to_shell_state(from)
		KoopaState.Shell:
			go_to_moving_shell_state(from)
		KoopaState.Moving_shell:
			go_to_shell_state(from)

func go_to_wondering_state():
	state = KoopaState.Wondering
	speed = walk_speed
	direction = [-1,1].pick_random()
	_change_direction()
	anim.play("walk")

func go_to_shell_state(from : Node2D):
	if from is Player:
		from.movement.ForceJump()
	GameSignals.add_score.emit(100, global_position)
	speed = 0
	state = KoopaState.Shell
	reset_state_timer.start()

func go_to_moving_shell_state(from : Node2D):
	if from is Player and not get_collision_normal(from).y > -COLLISION_NORMAL_THRESHOLD:
		from.movement.ForceJump()
	reset_state_timer.start()
	speed = shell_speed
	state = KoopaState.Moving_shell
	direction = sign(global_position.x - from.global_position.x)

func kill():
	get_node("CollisionShape2D").call_deferred("disabled", true)
	
	direction = 0.0
	anim.play("shell")
	
	SoundManager.play_sound(KICK_SOUND)
	GameSignals.add_score.emit(200, global_position)
	
	await get_tree().create_timer(.2).timeout
	queue_free()
