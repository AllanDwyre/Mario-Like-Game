extends EnemyBase

@onready var reset_state_timer: Timer = $ResetShapeTimer
@onready var anim : AnimatedSprite2D = $AnimatedSprite2D

var walk_speed : float
@export var shell_speed : float = 80.0 

func _ready() -> void:
	super()
	walk_speed = speed
	anim.play("walk")
	reset_state_timer.timeout.connect(_revive)
	
func _change_direction() -> void:
	super()
	anim.flip_h = direction > 0

func _revive():
	speed = walk_speed
	stunned = false
	anim.play("walk")
	
func _onHit():
	speed = shell_speed
	anim.play("shell")
	reset_state_timer.start()
	stunned = true
