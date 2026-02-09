extends Node

@export var background_color: Color = Color.SKY_BLUE
@export var level_music : AudioStream
const POINT_LABEL = preload("res://Prefabs/score_label.tscn")

const GAMEPLAY_VIEW = preload("res://Prefabs/Views/gameplay.tscn")

var gameplay_view : View
var timer : SceneTreeTimer
var coins : int

func _ready():
	RenderingServer.set_default_clear_color(background_color)
	SoundManager.play_music(level_music, 0.0)
	GameSignals.coin_collected.connect(add_coins)
	GameSignals.add_score.connect(instanciate_points)
	
	gameplay_view = GAMEPLAY_VIEW.instantiate()
	ViewManager.push(gameplay_view)
	
	timer = get_tree().create_timer(level_music.get_length())
	timer.timeout.connect(func(): GameSignals.level_finished.emit())

func _process(_delta: float) -> void:
	gameplay_view.set_time_left(timer.time_left)
	
func _exit_tree() -> void:
	GameSignals.coin_collected.disconnect(add_coins)
	

func add_coins():
	coins += 1
	gameplay_view.set_coins(coins)
	
func instanciate_points(point : int, g_pos : Vector2):
	var instance = POINT_LABEL.instantiate()
	instance.text = str(point)
	instance.global_position = g_pos
	add_child(instance)
	var tween = create_tween()
	tween.tween_property(instance, "global_position:y", g_pos.y - 8, 0.3)
	tween.tween_property(instance, "global_position:y", g_pos.y, 0.3)
	tween.tween_callback(func(): instance.queue_free())
