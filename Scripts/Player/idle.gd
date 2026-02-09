extends State

@export var anim : AnimatedSprite2D 

func Enter():
	anim.play("idle")

func Exit():
	pass

func Update(_delta : float):
	pass

func Physics_Update( _delta : float):
	pass
