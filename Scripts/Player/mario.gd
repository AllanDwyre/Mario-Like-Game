extends CharacterBody2D
class_name Mario 

#NOTE: this scripts used this documentation to make the movement :
# https://www.youtube.com/watch?v=u2fwxuHZXIA

const JUMP_SOUND = preload("res://Arts/Audios/Mario SFX/nsmb_jump.wav")
const HIT_SOUND = preload("res://Arts/Audios/Mario SFX/change_small.wav")
const DEATH_SOUND = preload("res://Arts/Audios/Mario SFX/nsmb_death.wav")

#region Movement Variables
## When shift not held
@export var walk_speed : float = 75.0
## When shift is held
@export var run_speed : float = 135.0
## When shift is held and the P-meter is full
@export var sprint_speed : float = 180.0

## When shift not held
@export var walk_accel : float = 337.5
## When shift not held but the direction is
@export var walk_decel : float = 562.5

## When shift is held
@export var run_accel : float = 337.5
## When shift held but the p_meter is not max
@export var run_decel : float = 1125.0

## When nothing is pressed (dir and run)
@export var stop_decel : float = 225.5

@export var p_meter_starting_speed : float = 131.25
@export var max_p_meter : float = 1.867

@export var jump_force : float = 150.0

@export var coyotte_duration : float = .3
@export var jump_buffer_duration : float = 0.15

var p_meter : float = 0.0
var speed : float = 0.0

#endregion
@onready var sprite : AnimatedSprite2D = $AnimatedSprite2D
@onready var collision_shape = $CollisionShape2D

#region State Variables
var machine : FiniteStateMachine
var context : PlayerContext

var idle : State
var run : State
var airborne : State
#endregion

# TODO: [x] each speed have is own acc and decel
# TODO: [x] P-meter jauge increase and decrese over time
# TODO: [ ] 
# TODO: [ ] level selector + transition effect (death + win)

enum PlayerSize {
	Small,
	Big,
}

var _size : PlayerSize = PlayerSize.Small

var collision_sizes = {
	PlayerSize.Small : Vector2(6, 16),
	PlayerSize.Big : Vector2(8, 32)
}

var is_dead : bool

func _ready() -> void:
	_init_state_machine()
	_update_collision()

func _init_state_machine():
	context = PlayerContext.new(self)
	idle = IdleState.new(context)
	run = RunState.new(context)
	airborne = AirborneState.new(context)
	machine = FiniteStateMachine.new(idle)

func _process(_delta: float) -> void:
	if not context.can_move:
		return
		
	context.is_grounded = is_on_floor()
	if Input.is_action_just_pressed("jump"):
		context.jump_pressed = true
	context.jump_released = Input.is_action_just_released("jump")
	context.direction = Input.get_axis("left", "right")
	context.run_pressed = Input.is_action_pressed("run")
	
	machine.Update(_delta)
	
		# Flip du sprite
	if abs(context.direction) > 0:
		context.sprite.flip_h = context.direction < 0
	
	# P-meter :
	p_meter += sign(velocity.x - p_meter_starting_speed) * _delta
	p_meter = clamp(p_meter, 0, max_p_meter)
	
	position.x = max(position.x, -256) # on clamp le player
	if position.y > 48 :
		kill()

func _physics_process(delta: float) -> void:
	if not context.can_move:
		return
	machine.Physics_Update(delta)

	#velocity.y = min(velocity.y, MAX_FALL_SPEED)
	move_and_slide()
	detect_collision()
	
#region Movement Methods
func p_meter_is_full() -> bool:
	return p_meter == max_p_meter

func _backward_direction_held() -> bool:
	return sign(context.mario.velocity.x) != sign(context.direction) and abs(context.mario.velocity.x) > 0.1
	
func _max_speed() -> float:
	var base_speed : float
	if p_meter_is_full():
		base_speed = sprint_speed
	elif context.run_pressed :
		base_speed = run_speed
	else :
		base_speed = walk_speed
	return base_speed * context.direction

func _base_accel() -> float:
	var base_accel : float
	if context.run_pressed or p_meter_is_full():
		base_accel = run_accel
	else :
		base_accel = walk_decel
	return base_accel

func _base_decel() -> float:
	var base_decel : float
	if context.run_pressed and not p_meter_is_full():
		base_decel = run_decel
	elif not context.run_pressed and abs(context.direction) > 0:
		base_decel = walk_decel
	else:
		base_decel = stop_decel
	return base_decel

func _accelerate(accel : float, target_speed : float, delta : float):
	velocity.x = move_toward(velocity.x, target_speed, accel * delta)

func _decelerate(decel : float, delta: float):
	velocity.x = move_toward(velocity.x, 0, decel * delta)

func handle_movement(delta : float):
	var target_speed : float = _max_speed()
	var accel : float = _base_accel()
	var decel : float = _base_decel()
	var force_decel : float = stop_decel
	
	# if we are in the air and don't use movement, we keep the same velocity (not accel or decel)
	if not is_on_floor() and not context.direction:
		return
	
	#TODO : handle ducking with force decel
	
	# if the velocity is below the max speed we accelerate
	if abs(velocity.x) < abs(target_speed) and not _backward_direction_held():
		_accelerate(accel, target_speed, delta)
		return
		
	if _backward_direction_held():
		_decelerate(decel, delta)
		return
	
	if abs(velocity.x) >= abs(target_speed) and (is_on_floor() or _backward_direction_held()):
		_decelerate(force_decel, delta)
		return

func jump():
	sprite.play(str(context.size) + "_jump")
	SoundManager.play_sound(JUMP_SOUND)
	
	var height_bonus = abs(velocity.x) * 0.15
	
	velocity.y = -(jump_force + height_bonus)
	
	context.has_jumped = true
	context.jump_pressed = false

#endregion

#region Public methods
func play_anim(anim_name : String, flip : bool = false) -> void :
	sprite.play(get_size() + "_" + anim_name)
	sprite.flip_h = flip

func _set_size(size : PlayerSize):
	_size = size
	_update_collision()
	
func get_size() -> String:
	return PlayerSize.keys()[_size].to_lower()
	
func power_up():
	SoundManager.play_sound(load("res://Arts/Audios/Mario SFX/nsmb_power-up.wav"))
	_set_size(PlayerSize.Big)
#
func set_can_move(can : bool):
	context.can_move = can

func kill() -> void :
	if is_dead:
		return
	
	set_physics_process(false)
	set_process(false)
	
	is_dead = true
	context.can_move = false
	GameSignals.player_died.emit()
	SoundManager.pause_music()
	sprite.play("death")
	SoundManager.play_sound(DEATH_SOUND)
	
	var tween = get_tree().create_tween()
	tween.tween_property(self, "global_position:y", global_position.y - 64, .5)
	tween.tween_property(self, "global_position:y", 64, 1)

func _update_collision() -> void :
	collision_shape.shape.set_size(collision_sizes[_size])

func detect_collision():
	for i in range(get_slide_collision_count()):
		var collision = get_slide_collision(i)
		var collider = collision.get_collider()
		if collider.is_in_group("Interactables"):
			collider.interact(self)
	
func take_damage(_from : Node2D ):
	if _size == PlayerSize.Small:
		kill()
	else:
		SoundManager.play_sound(HIT_SOUND)
		_set_size(PlayerSize.Small)
 #endregion
