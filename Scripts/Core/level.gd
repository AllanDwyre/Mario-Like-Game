extends Node	
class_name Level

@export var background_color: Color = Color.SKY_BLUE
@export var level_music : AudioStream
@export var spawns : Array[Marker2D]

const POINT_LABEL = preload("res://Prefabs/score_label.tscn")

var timer : SceneTreeTimer
var coins : int

func _ready():
	RenderingServer.set_default_clear_color(background_color)
	SoundManager.play_music(level_music)
	
	GameSignals.coin_collected.connect(add_coins)
	GameSignals.add_score.connect(instanciate_points)
	# plus tard, sera gerer par une node parent (qui permetra de handle la coop)
	setup_player()

func setup_player():
	for p in get_tree().get_nodes_in_group("Player"):
		p = p as Player
		p.setup_player(PlayerInfo.new(-1, true))

func _exit_tree() -> void:
	GameSignals.coin_collected.disconnect(add_coins)
	GameSignals.add_score.disconnect(instanciate_points)

func add_coins():
	coins += 1
func instanciate_points(point : int, g_pos : Vector2):
	var instance = POINT_LABEL.instantiate()
	instance.text = str(point)
	instance.global_position = g_pos
	add_child(instance)
	var tween = create_tween()
	tween.tween_property(instance, "global_position:y", g_pos.y - 16, 0.4)
	tween.tween_callback(func(): instance.queue_free())
