extends State
class_name MovementState

var context : PlayerContext
var movement : Movement

#region Getter/Setter
var sprite : AnimatedSprite2D :
	get : return context.player.sprite
	
var size : String :
	get : return  context.player.get_size()
	
var velocity : Vector2 :
	get : return context.velocity
	set(value) : context.velocity = value
#endregion

#region Helper Functions
func is_against_wall() -> bool: 
	if not context.player.is_on_wall_only():
		return false
	var pusing_against_wall = context.direction != 0.0 and sign(context.player.get_wall_normal().x) != sign(context.direction)
	return pusing_against_wall

func jump(force : float, jump_dir : Vector2 = Vector2.UP) -> void:
	context.velocity.y = force * jump_dir.y
	
	if abs(jump_dir.x) > 0:
		context.velocity.x = force * jump_dir.x

func p_meter_is_full() -> bool:
	return context.p_meter == movement.max_p_meter

func _backward_direction_held() -> bool:
	return sign(context.velocity.x) != sign(context.direction) and abs(context.velocity.x) > 0.1

func _max_speed() -> float:
	var base_speed : float
	if p_meter_is_full():
		base_speed = movement.sprint_speed
	elif context.run_pressed :
		base_speed = movement.run_speed
	else :
		base_speed = movement.walk_speed
	return base_speed * context.direction

func _base_accel() -> float:
	var base_accel : float
	if context.run_pressed or p_meter_is_full():
		base_accel = movement.run_accel
	else :
		base_accel = movement.walk_decel
	return base_accel

func _base_decel() -> float:
	var base_decel : float
	if context.run_pressed and not p_meter_is_full():
		base_decel = movement.run_decel
	elif not context.run_pressed and abs(context.direction) > 0:
		base_decel = movement.walk_decel
	else:
		base_decel = movement.stop_decel
	return base_decel

func _accelerate(accel : float, target_speed : float, delta : float):
	context.velocity.x = move_toward(context.velocity.x, target_speed, accel * delta)

func _decelerate(decel : float, delta: float):
	context.velocity.x = move_toward(context.velocity.x, 0, decel * delta)

func handle_movement(delta : float):
	var target_speed : float = _max_speed()
	var accel : float = _base_accel()
	var decel : float = _base_decel()
	var force_decel : float = movement.stop_decel
	
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

func _init(context_ : PlayerContext) -> void:
	context = context_
	movement = context.player.movement
