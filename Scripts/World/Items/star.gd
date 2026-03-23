class_name Starman
extends Area2D

signal star_tooked(player_id : int)

func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		star_tooked.emit(body.player_info.primary_device_id)
		call_deferred("exit") # to do it after the frame

func exit():
	# Do cool shit : Like rotations etc ..
	queue_free()
