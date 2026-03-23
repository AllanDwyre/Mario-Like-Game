extends MovementState
class_name IdleState

func Enter():
	sprite.play(size + "_idle")

func Exit():
	pass

func Update(_delta : float):
	pass

func Physics_Update( _delta : float):
	# Pas de direction = décélération naturelle
	if context.jump_pressed: 
		jump(movement.jump_force)
	
	handle_movement(_delta)

func GetTransition() -> State:
	if velocity.y < 0:
		return movement.jump_state
		
	if not context.is_grounded :
		return movement.fall_state
		
	if abs(context.direction) > 0:
		return movement.run_state
	return null
