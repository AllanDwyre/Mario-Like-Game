extends MovementState
class_name RunState

func Enter():
	sprite.play(size + "_run")

func Exit():
	pass

func Update(_delta : float):
	pass

func Physics_Update(_delta : float):
	if context.jump_pressed:
		jump(movement.jump_force)
	
	handle_movement(_delta)

func GetTransition() -> State:
	if velocity.y < 0:
		return movement.jump_state
	
	if not context.is_grounded :
		return movement.fall_state
	
	if context.direction == 0.0:
		return movement.idle_state

	return null
