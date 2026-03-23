extends Node
# --- Autoload - Settings.gd ---

const SAVE_PATH = "user://settings.cfg"
var config := ConfigFile.new()

# Define your settings with defaults
var default_settings := {
	"volume_master": 1.0,
	"volume_music": 1.0,
	"volume_sfx": 1.0,
	"fullscreen": DisplayServer.WINDOW_MODE_WINDOWED,
	"resolution": Vector2i(1152, 648),
	"controller_vibrations": true,
	"screen_shake": true,
	"language": "en",
	# resolutions (screen size), keyboard config, controller config, accessibility
}
# NOTE : On pourrait faire des gets pour chaque settings ou du moins les plus demander.

@onready var settings = default_settings
# ==========================================

#region Core API
func _ready() -> void:
	load_settings()

func set_setting(key: String, value) -> void:
	settings[key] = value
	save_settings()

func get_setting(key: String):
	return settings.get(key)

func save_settings() -> void:
	for key in settings:
		config.set_value("settings", key, settings[key])
	config.save(SAVE_PATH)

func load_settings() -> void:
	if config.load(SAVE_PATH) == OK:
		for key in settings:
			settings[key] = config.get_value("settings", key, settings[key])
#endregion
# ==========================================

#region Audio Helpers
func get_volume_master() -> float:
	return settings.get("volume_master", 1.0)

func get_volume_music() -> float:
	return settings.get("volume_music", 1.0)

func get_volume_sfx() -> float:
	return settings.get("volume_sfx", 1.0)

func set_volume_master(value: float) -> void:
	#SoundManager.set_music_volume(value)
	set_setting("volume_master", clampf(value, 0.0, 1.0))

func set_volume_music(value: float) -> void:
	SoundManager.set_music_volume(value)
	set_setting("volume_music", clampf(value, 0.0, 1.0))

func set_volume_sfx(value: float) -> void:
	SoundManager.set_sfx_volume(value)
	set_setting("volume_sfx", clampf(value, 0.0, 1.0))

#endregion
# ==========================================

#region Display Helpers
func is_fullscreen() -> bool:
	return settings.get("fullscreen") == DisplayServer.WINDOW_MODE_FULLSCREEN

func set_fullscreen(enabled: bool) -> void:
	var mode := DisplayServer.WINDOW_MODE_FULLSCREEN if enabled else DisplayServer.WINDOW_MODE_WINDOWED
	DisplayServer.window_set_mode(mode)
	set_setting("fullscreen", mode)

func get_resolution() -> Vector2i:
	return settings.get("resolution", Vector2i(1152, 648))

func set_resolution(res: Vector2i) -> void:
	set_setting("resolution", res)
	get_window().size = res
	if is_fullscreen():
		get_window().content_scale_size = res
	else:
		var screen_size := DisplayServer.screen_get_size()
		get_window().position = (screen_size - res) / 2.0
#endregion
# ==========================================

#region Game Helpers

func set_controller_vibration(enable : bool):
	settings.set("controller_vibrations", enable)

func is_controller_vibration_enabled() -> bool:
	return settings.get("controller_vibrations", true)

func is_screen_shake_enabled() -> bool:
	return settings.get("screen_shake", true)

func get_language() -> String:
	return settings.get("language", "en")
#endregion
# ==========================================
