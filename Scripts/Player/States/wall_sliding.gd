extends MovementState
class_name WallSlidingState

# slide freeze au debut : ne pas glissé les x premières frames
# mettre un temps max de slide avant de fall (2s)
# Faire une jump spécial wall (ne pas pouvoir changer le mouvement)
func Enter():
	velocity.y = max(velocity.y, 0) # Stop all type of jump
	sprite.play(size + "_jump")

func Exit():
	context.buffered_timer = 0.0

func Update(_delta : float):
	pass

func Physics_Update(_delta : float):
	if is_against_wall() and context.jump_pressed:
		var jump_dir = Vector2(-context.direction, -2).normalized()
		jump(movement.jump_force, jump_dir)
		context.has_wall_jumped = true
	else:
		velocity.y = movement.wall_sliding_speed # move_toward(velocity.y, movement.wall_sliding_speed, movement.stop_decel * delta)

func GetTransition() -> State:
	if velocity.y < 0:
		return movement.jump_state
	# Sur le sol sans bouger
	if context.is_grounded and context.direction == 0.0:
		return movement.idle_state
	# N'appuye plus contre le mur
	elif not is_against_wall():
		return movement.fall_state
	
	return null
