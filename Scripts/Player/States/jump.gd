extends MovementState
class_name JumpState 

const JUMP_SOUND = preload("res://Arts/Audios/Mario SFX/nsmb_jump.wav")
const REDUCE_MOMENTUM_RATIO : float = 0.5

var has_been_released = false

# TODO : ADD a jump slide of edge mecanics ? https://youtu.be/Bsy8pknHc0M?t=187

# NOTE : Smash bros melee has the jumpsquat frames, where upon pressing the jump button,
# it delays jumping by like 3-8 frames (depending on the char). IIRC if the jump button
# is still held after the jumpsquat frames end you do a fullhop, 
# and if you release jump before the jumpsquat frames end you do a shorthop. 

func Enter():
	SoundManager.play_sound(JUMP_SOUND)
	movement.jumped.emit()
	has_been_released = false
	
	context.has_jumped = true
	context.jump_pressed = false

func Exit():
	context.has_wall_jumped = false
	context.buffered_timer = 0.0

func Update(_delta : float):
	if context.buffered_timer <= 0.0:
		context.jump_pressed = false
	else :
		context.buffered_timer -= _delta

func Physics_Update( _delta : float):
	context.velocity += context.player.get_gravity() * _delta
	
	if context.jump_released and not has_been_released:
		has_been_released = true
		velocity.y *= REDUCE_MOMENTUM_RATIO
	
	# if we are in the air and don't use movement, we keep the same velocity (not accel or decel)
	if not context.is_grounded and not context.direction:
		return
	# If its a wall jump, we don't want the player to be able to move until he reach the fall state
	if context.has_wall_jumped:
		return
	handle_movement(_delta)


func GetTransition() -> State:
	#if is_against_wall():
		#return movement.wall_sliding_state
	if velocity.y > 0:
		return movement.fall_state
	
	# N'arrivera jamais théoriquement
	#if context.is_grounded:
		#return movement.run_state if abs(context.direction) > 0 else movement.idle_state
	return null
