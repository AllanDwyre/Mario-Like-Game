extends Node
class_name Movement

var player : Player

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

@export var jump_force : float = 350.0

@export var coyotte_duration : float = .15
@export var jump_buffer_duration : float = 0.15

@export var wall_sliding_speed : float = 45.5
#endregion

#region State Variables
var machine : FiniteStateMachine
var context : PlayerContext

var idle_state : State
var run_state : State
var jump_state : State
var fall_state : State
var wall_sliding_state : State
#endregion

#region Signals
@warning_ignore("UNUSED_SIGNAL")
signal jumped
#endregion

func set_up(player_: Player, context_ : PlayerContext):
	context = context_
	player = player_
	
	idle_state = IdleState.new(context)
	run_state = RunState.new(context)
	jump_state = JumpState.new(context)
	fall_state = FallState.new(context)
	wall_sliding_state = WallSlidingState.new(context)
	machine = FiniteStateMachine.new(idle_state)

func Update(delta: float) -> void:
	#DebugDraw2D.set_text(machine.currentState.get_script().get_global_name())
	if not context.can_move:
		context.p_meter = 0
		return
		
	machine.Update(delta)
	
	if abs(context.direction) > 0:
		player.sprite.flip_h = context.direction < 0
		
	# P-meter :
	context.p_meter += sign(player.velocity.x - p_meter_starting_speed) * delta
	context.p_meter = clamp(context.p_meter, 0, max_p_meter)

func PhysicUpdate(delta: float) -> void:
	if not context.can_move:
		return
	
	handle_floor()
	
	machine.Physics_Update(delta)
	player.move_and_slide()

func handle_floor():
	# Si on etait en l'air et que l'on touche le sol
	if not context.is_grounded and player.is_on_floor() :
		context.has_jumped = false
	# Si on etait sur sol et que l'on est plus
	elif context.is_grounded and not player.is_on_floor() :
		context.coyotte_timer = coyotte_duration
	
	context.is_grounded = player.is_on_floor()

func ForceJump():
	(machine.currentState as MovementState).jump(jump_force)
	machine.Change_state(jump_state)

#region Movement Methods
func p_meter_is_full() -> bool:
	return context.p_meter == max_p_meter

func _backward_direction_held() -> bool:
	return sign(context.velocity.x) != sign(context.direction) and abs(context.velocity.x) > 0.1

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
	context.velocity.x = move_toward(context.velocity.x, target_speed, accel * delta)

func _decelerate(decel : float, delta: float):
	context.velocity.x = move_toward(context.velocity.x, 0, decel * delta)

func handle_movement(delta : float):
	var target_speed : float = _max_speed()
	var accel : float = _base_accel()
	var decel : float = _base_decel()
	var force_decel : float = stop_decel
	
	# if we are in the air and don't use movement, we keep the same velocity (not accel or decel)
	if not context.is_grounded and not context.direction:
		return
	
	#TODO : handle ducking with force decel
	
	# if the velocity is below the max speed we accelerate
	if abs(context.velocity.x) < abs(target_speed) and not _backward_direction_held():
		_accelerate(accel, target_speed, delta)
		return
		
	if _backward_direction_held():
		_decelerate(decel, delta)
		return
	
	if abs(context.velocity.x) >= abs(target_speed) and (context.is_grounded or _backward_direction_held()):
		_decelerate(force_decel, delta)
		return
#endregion
