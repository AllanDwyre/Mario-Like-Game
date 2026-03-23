extends Area2D
const COIN_SOUND = preload("res://Arts/Audios/SFX/nsmb_coin.wav")

const FLIP_INTERVAL = 0.4

var timer : Timer
@onready var sprite : Sprite2D = $Sprite2D

func _on_body_entered(body: Node2D) -> void:
	if not body.is_in_group("Player"):
		return
	GameSignals.add_score.emit(100, global_position)
	SoundManager.play_sound(COIN_SOUND)
	GameSignals.coin_collected.emit()
	queue_free()

func _ready() -> void:
	timer = Timer.new()
	add_child(timer)
	timer.timeout.connect(func() : sprite.flip_h = !sprite.flip_h )
	timer.start(FLIP_INTERVAL)
