extends Area2D
const COIN_SOUND = preload("res://Arts/Audios/SFX/nsmb_coin.wav")

func _on_body_entered(body: Node2D) -> void:
	if not body.is_in_group("Player"):
		return
	GameSignals.add_score.emit(100, global_position)
	SoundManager.play_sound(COIN_SOUND)
	GameSignals.coin_collected.emit()
	queue_free()
