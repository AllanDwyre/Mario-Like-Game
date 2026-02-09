class_name AirborneState extends State

var context : PlayerContext

## represent the time in the air where you can still jump
var coyotte_timer : float

## represent the countdown where your jump is still requested for the landing
var buffered_timer : float

const REDUCE_MOMENTUM_RATIO : float = 0.4

func _init(context : PlayerContext) -> void:
	self.context = context

func Enter():
	coyotte_timer = context.mario.coyotte_duration
	buffered_timer = context.mario.jump_buffer_duration

func Exit():
	context.has_jumped = false

func Update(_delta : float):
	coyotte_timer -= _delta
	
	if context.jump_pressed:
		buffered_timer = context.mario.jump_buffer_duration  # Reset le timer
	else:
		buffered_timer -= _delta
	
	if buffered_timer <= 0.0:
		context.jump_pressed = false

func Physics_Update( _delta : float):
	context.mario.velocity += context.mario.get_gravity() * _delta
	
	if context.jump_pressed and coyotte_timer > 0.0 and not context.has_jumped:
		context.mario.jump()
		context.has_jumped = true
	
	# Variable jump height ( not falling + jump button released
	if context.jump_released && context.mario.velocity.y < 0: 
		context.mario.velocity.y *= REDUCE_MOMENTUM_RATIO
	
	context.mario.handle_movement(_delta)


func GetTransition() -> State:
	if context.is_grounded:
		return context.mario.run if abs(context.direction) > 0 else context.mario.idle
	return null
