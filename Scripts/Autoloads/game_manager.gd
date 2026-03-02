extends Node2D

# Setup game (go to game settting and only ViewManager)
# Start the game (clear view -> change scene + Transition -> ViewManager for each split screen)
# Setting screen (only ViewManager)
# gameover (only ViewManager)
# open pause menu (only ViewManager)
# ...
var entry_scene : PackedScene = load("res://Prefabs/Views/main_menu.tscn")

var pending_config : Variant

#func _ready() -> void:
	#SceneManager.change_scene(entry_scene)

func start_solo_game(target_scene : PackedScene, transition : BaseTransition = InstantTransition.new(),):
	if SceneManager.is_transitioning:
		push_warning("cannot start_versus_game, the scene is already transitionning")
		return
	pending_config = null # On consume config
	# go to world scene
	SceneManager.change_scene(target_scene, transition)
	ViewManager.clear_history()

func start_versus_game(target_scene : PackedScene, lobby_setting : VersusLobbySettings, transition : BaseTransition = InstantTransition.new(),):
	if SceneManager.is_transitioning:
		push_warning("cannot start_versus_game, the scene is already transitionning")
		return
	pending_config = lobby_setting
	# go to world scene
	SceneManager.change_scene(target_scene, transition)
	ViewManager.clear_history()

## Utiliser pour que les scenes enfants font la requete sans savoir si elles on été lancé en debug,
## ou non. Cela permet de recuperer leur config
func consume_config():
	var pg = pending_config
	pending_config = null
	return pg
