class_name MainMenuView
extends View

@export var first_focus : Control
@export var solo_scene : PackedScene
@export var versus_scene : PackedScene
@export var setting_scene : PackedScene
@export var main_menu_music : AudioStream

func _ready() -> void:
	ViewManager.history.append(self)
	SoundManager.play_music(main_menu_music)

func show_view():
	super()
	first_focus.grab_focus()

func _on_story_play_button_pressed() -> void:
	GameManager.start_solo_game(solo_scene, InstantTransition.new())

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
