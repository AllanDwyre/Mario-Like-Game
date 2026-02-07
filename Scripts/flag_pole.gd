extends Sprite2D

signal level_finished

@export var duration = 1

@onready var flag = $Flag
@onready var castle = $Castle
@onready var raycast = $RayCast2D

var player_collided = false
var player : Node2D

func _process(delta: float) -> void:
	if not player_collided and raycast.is_colliding():
		finish_level(raycast)
	
func finish_level(hit : RayCast2D):
	player_collided = true
	player = raycast.get_collider()
	player.can_move = false
	
	var tween = create_tween()
	var flag_target_y = player.global_position.y
	tween.tween_property(flag, "global_position:y", flag_target_y, duration)
	
	tween.parallel().tween_property(player, "global_position:y", 0.0, duration).set_delay(duration * 0.1)
	tween.parallel().tween_callback(func(): player.play_anim("slide"))
	tween.tween_callback(func(): player.play_anim("run"))
	tween.tween_property(player, "global_position:x", castle.global_position.x, duration)
	tween.tween_property(player, "modulate", Color.TRANSPARENT, duration / 2.0)
	
	
