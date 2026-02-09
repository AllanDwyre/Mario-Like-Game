extends Node

@export var background_color: Color = Color.SKY_BLUE
@export var level_music : AudioStream

const GAMEPLAY_VIEW = preload("res://Prefabs/Views/gameplay.tscn")

var gameplay_view : View
var timer : SceneTreeTimer
var coins : int

func _ready():
	RenderingServer.set_default_clear_color(background_color)
	SoundManager.play_music(level_music, 0.0)
	GameSignals.coin_collected.connect(add_coins)
	
	gameplay_view = GAMEPLAY_VIEW.instantiate()
	ViewManager.push(gameplay_view)
	
	timer = get_tree().create_timer(level_music.get_length())

func add_coins():
	coins += 1
	gameplay_view.set_coins(coins)

func _process(_delta: float) -> void:
	gameplay_view.set_time_left(timer.time_left)
	
func _exit_tree() -> void:
	GameSignals.coin_collected.disconnect(add_coins)
	
