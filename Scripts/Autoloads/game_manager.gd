extends Node2D
enum EGameMode {Menu, Solo, Versus }

var entry_scene : PackedScene = load("res://Prefabs/Views/main_menu.tscn")

var current_gamemode : EGameMode = EGameMode.Menu
var pending_config : Variant

func _ready() -> void:
	apply_settings()

# TODO : a deplacer dans le autoload settings
func apply_settings():
	Settings.load_settings()
	DisplayServer.window_set_mode(Settings.get_setting("fullscreen"))
	get_window().size = Settings.get_setting("resolution")
	if Settings.get_setting("fullscreen") == DisplayServer.WINDOW_MODE_FULLSCREEN:
		get_window().content_scale_size = get_window().size
	else:
		var screen_size = DisplayServer.screen_get_size()
		get_window().position = (screen_size - get_window().size) / 2.0

#region Game State Methods Logic
func start_solo_game(solo_settings : SoloSettings, transition : BaseTransition = InstantTransition.new()):
	var level_handler : PackedScene = load("res://Scenes/story_level_handler.tscn")
	if SceneManager.is_transitioning:
		push_warning("cannot start_versus_game, the scene is already transitionning")
		return
	pending_config = solo_settings
	current_gamemode = EGameMode.Solo
	SceneManager.change_scene(level_handler, transition)

func start_versus_game(lobby_settings : VersusSettings, transition : BaseTransition = InstantTransition.new()):
	var level_handler : PackedScene = load("res://Scenes/versus_level_handler.tscn")
	if SceneManager.is_transitioning:
		push_warning("cannot start_versus_game, the scene is already transitionning")
		return
	pending_config = lobby_settings
	current_gamemode = EGameMode.Versus
	SceneManager.change_scene(level_handler, transition)
#endregion

#region Utils
## Utiliser pour que les scenes enfants font la requete sans savoir si elles on été lancé en debug,
## ou non. Cela permet de recuperer leur config
func consume_config():
	var pg = pending_config
	pending_config = null
	return pg
#endregion
