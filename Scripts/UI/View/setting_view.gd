class_name GameSettingView
extends View


@export var music_slider : HSlider
@export var sfx_slider : HSlider
@export var controller_vibrations : CheckButton

const MUSIC_SETTING = "volume_music"
const SFX_SETTING = "volume_sfx"
const CONTROLLER_VIBRATION_SETTING = "controller_vibrations"

func _ready() -> void:
	music_slider.value = SoundManager.get_music_volume()
	sfx_slider.value = SoundManager.get_sfx_volume()
	controller_vibrations.button_pressed = Settings.get_setting(CONTROLLER_VIBRATION_SETTING)

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
