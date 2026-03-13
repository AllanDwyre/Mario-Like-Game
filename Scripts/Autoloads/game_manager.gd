extends Node2D

# Setup game (go to game settting and only ViewManager)
# Start the game (clear view -> change scene + Transition -> ViewManager for each split screen)
# Setting screen (only ViewManager)
# gameover (only ViewManager)
# open pause menu (only ViewManager)
# go back to main menu
# ...

var entry_scene : PackedScene = load("res://Prefabs/Views/main_menu.tscn")
var pending_config : Variant

var rule_set: RuleSet

enum EGameMode {
	None,
	Solo,
	Versus
}
var current_gamemode : EGameMode = EGameMode.None

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

func start_solo_game(target_scene : Variant, solo_settings : SoloSettings, transition : BaseTransition = InstantTransition.new(),):
	if SceneManager.is_transitioning:
		push_warning("cannot start_versus_game, the scene is already transitionning")
		return
	pending_config = solo_settings
	rule_set = SoloRuleSet.new()
	current_gamemode = EGameMode.Solo
	SceneManager.change_scene(target_scene, transition)

func start_versus_game(target_scene : Variant, lobby_settings : VersusSettings, transition : BaseTransition = InstantTransition.new(),):
	if SceneManager.is_transitioning:
		push_warning("cannot start_versus_game, the scene is already transitionning")
		return
	pending_config = lobby_settings
	current_gamemode = EGameMode.Versus
	rule_set = VersusRuleSet.new()
	SceneManager.change_scene(target_scene, transition)

## Utiliser pour que les scenes enfants font la requete sans savoir si elles on été lancé en debug,
## ou non. Cela permet de recuperer leur config
func consume_config():
	var pg = pending_config
	pending_config = null
	return pg
