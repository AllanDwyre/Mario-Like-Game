extends Node2D

# Setup game (go to game settting and only ViewManager)
# Start the game (clear view -> change scene + Transition -> ViewManager for each split screen)
# Setting screen (only ViewManager)
# gameover (only ViewManager)
# open pause menu (only ViewManager)
# ...
var entry_scene : PackedScene = load("res://Prefabs/Views/main_menu.tscn")
var pending_config : Variant
var rule_set: RuleSet

func _ready() -> void:
	apply_settings()

func apply_settings():
	Settings.load_settings()
	DisplayServer.window_set_mode(Settings.get_setting("fullscreen"))
	get_window().size = Settings.get_setting("resolution")
	if Settings.get_setting("fullscreen") == DisplayServer.WINDOW_MODE_FULLSCREEN:
		get_window().content_scale_size = get_window().size
	else:
		var screen_size = DisplayServer.screen_get_size()
		get_window().position = (screen_size - get_window().size) / 2.0

func start_solo_game(target_scene : PackedScene, transition : BaseTransition = InstantTransition.new(),):
	if SceneManager.is_transitioning:
		push_warning("cannot start_versus_game, the scene is already transitionning")
		return
	pending_config = null # On consume config
	rule_set = SoloRuleSet.new()
	SceneManager.change_scene(target_scene, transition)

func start_versus_game(target_scene : PackedScene, lobby_setting : VersusLobbySettings, transition : BaseTransition = InstantTransition.new(),):
	if SceneManager.is_transitioning:
		push_warning("cannot start_versus_game, the scene is already transitionning")
		return
	pending_config = lobby_setting
	rule_set = VersusRuleSet.new()
	SceneManager.change_scene(target_scene, transition)

## Utiliser pour que les scenes enfants font la requete sans savoir si elles on été lancé en debug,
## ou non. Cela permet de recuperer leur config
func consume_config():
	var pg = pending_config
	pending_config = null
	return pg
