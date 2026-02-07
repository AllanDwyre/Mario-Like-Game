extends EnemyBase

@onready var anim : AnimatedSprite2D = $AnimatedSprite2D

func _ready() -> void:
	super()
	anim.play("walk")

func _change_direction() -> void:
	super()
	anim.flip_h = direction > 0
	
func _onHit() -> void :
	if died:
		return
		
	anim.play("death")
	var tween = get_tree().create_tween()
	tween.tween_property(anim, "position:y", anim.position.y - 8, .1)
	tween.tween_property(anim, "position:y", 64,.5)
	tween.tween_callback(queue_free)
