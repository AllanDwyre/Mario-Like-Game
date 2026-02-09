class_name RunState extends State

var context : PlayerContext

func _init(context : PlayerContext) -> void:
	self.context = context

func Enter():
	context.sprite.play(context.size + "_run")

func Exit():
	pass

func Update(_delta : float):
	pass

func Physics_Update(_delta : float):
	if context.jump_pressed and context.is_grounded:
		context.mario.jump()
	
	context.mario.handle_movement(_delta)


func GetTransition() -> State:
	if context.direction == 0.0:
		return context.mario.idle
	
	if not context.is_grounded :
		return context.mario.airborne
	return null
