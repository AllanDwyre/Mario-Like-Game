class_name GameSettingView
extends View


@export var music_slider : HSlider
@export var sfx_slider : HSlider
@export var controller_vibrations : CheckButton
@export var fullscreen_toggle : CheckButton
@export var resolution_btn : OptionButton

const MUSIC_SETTING = "volume_music"
const SFX_SETTING = "volume_sfx"
const CONTROLLER_VIBRATION_SETTING = "controller_vibrations"
const FULLSCREEN_SETTING = "fullscreen"
const RESOLUTION_SETTING = "resolution"

var _resolutions : Dictionary[StringName, Vector2i]

func show_view():
	super()
	music_slider.grab_focus()

func _ready() -> void:
	music_slider.value = SoundManager.get_music_volume()
	sfx_slider.value = SoundManager.get_sfx_volume()
	controller_vibrations.button_pressed = Settings.get_setting(CONTROLLER_VIBRATION_SETTING)
	fullscreen_toggle.button_pressed = Settings.get_setting(FULLSCREEN_SETTING)
	
	_resolutions = ResolutionUtil.retrieve_possible_resolutions()
	for key in _resolutions.keys():
		resolution_btn.add_item(key)
	var current_res = Settings.get_setting(RESOLUTION_SETTING)
	for i in range(resolution_btn.get_item_count()):
		if _resolutions[resolution_btn.get_item_text(i)] == current_res:
			resolution_btn.select(i)
			break

func _on_back_button_pressed() -> void:
	ViewManager.pop()

func _on_music_slider_value_changed(value: float) -> void:
	SoundManager.set_music_volume(value)
	Settings.set_setting(MUSIC_SETTING, value)

func _on_sound_effect_slider_value_changed(value: float) -> void:
	SoundManager.set_sfx_volume(value)
	Settings.set_setting(SFX_SETTING, value)

func _on_controller_vibrations_button_toggled(toggled_on: bool) -> void:
	Settings.set_setting(CONTROLLER_VIBRATION_SETTING, toggled_on)

func _on_fullscreen_button_toggled(toggled_on: bool) -> void:
	var mode;
	match toggled_on:
		true : mode = DisplayServer.WINDOW_MODE_FULLSCREEN
		false : mode = DisplayServer.WINDOW_MODE_WINDOWED
	DisplayServer.window_set_mode(mode)
	Settings.set_setting(FULLSCREEN_SETTING, mode)


func _on_resolution_button_item_selected(index: int) -> void:
	var res = _resolutions.get(resolution_btn.get_item_text(index), Vector2i(1152, 648))
	Settings.set_setting(RESOLUTION_SETTING, res)
	get_window().size = res
	if Settings.get_setting(FULLSCREEN_SETTING) == DisplayServer.WINDOW_MODE_FULLSCREEN:
		get_window().content_scale_size = res
	else:
		var screen_size = DisplayServer.screen_get_size()
		get_window().position = (screen_size - res) / 2
