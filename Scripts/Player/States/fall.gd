extends MovementState
class_name FallState

func Enter():
	sprite.play(size + "_jump")

func Exit():
	#Input.start_joy_vibration(0,.3,.8,.3)
	#Input.set_joy_light(0, Color.PALE_GREEN)
	# impact particule and sound
	context.buffered_timer = 0.0

func Update(_delta : float):
	context.coyotte_timer -= _delta

	if context.buffered_timer <= 0.0:
		context.jump_pressed = false
	else :
		context.buffered_timer -= _delta

func Physics_Update(_delta : float):
	context.velocity += context.player.get_gravity() * _delta
	
	# jump si il n'a pas déja jump en l'air et que le coyotte timer a encore du temps
	if not context.has_jumped and context.jump_pressed and context.coyotte_timer > 0.0:
		jump(movement.jump_force)
		
	# if we are in the air and don't use movement, we keep the same velocity (not accel or decel)
	if not context.is_grounded and not context.direction:
		return
	handle_movement(_delta)

func GetTransition() -> State:
	if is_against_wall():
		return movement.wall_sliding_state
	
	if context.is_grounded:
		return movement.run_state if abs(context.direction) > 0 else movement.idle_state
	
	if velocity.y < 0:
		return movement.jump_state
	
	return null
