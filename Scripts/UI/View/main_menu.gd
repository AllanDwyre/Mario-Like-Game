class_name MainMenuView
extends View

@export var first_focus : Control
@export var solo_scene : PackedScene
@export var versus_scene : PackedScene
@export var setting_scene : PackedScene
@export var main_menu_music : AudioStream

func _ready() -> void:
	ViewManager.insert(self)
	SoundManager.play_music(main_menu_music)

func show_view():
	super()
	first_focus.grab_focus()

func _on_story_play_button_pressed() -> void:
	# TODO : Go to the world view / map selection view
	var level_handler_scene: StringName = "res://Scenes/level_handler.tscn"
	var setting = SoloSettings.new()
	setting.level = "res://Scenes/levels/level_1.tscn"
	GameManager.start_solo_game(level_handler_scene, setting)

func _on_versus_play_button_pressed() -> void:
	# --- local versus instantation ---
	var versus_view = versus_scene.instantiate()
	assert(versus_view is VersusSettingView, "MainMenuView : versus_scene isn't a VersusSettingView")
	ViewManager.push(versus_view)

func _on_settings_pressed() -> void:
	var setting_view = setting_scene.instantiate()
	assert(setting_view is GameSettingView, "MainMenuView : setting_scene isn't a GameSettingView")
	ViewManager.push(setting_view)

func _on_quit_pressed() -> void:
	print("quit game requested")
	get_tree().quit()
