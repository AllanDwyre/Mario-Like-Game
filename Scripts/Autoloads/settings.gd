extends Node
# Settings.gd

const SAVE_PATH = "user://settings.cfg"
var config := ConfigFile.new()

# Define your settings with defaults
var default_settings := {
	"volume_master": 1.0,
	"volume_music": 1.0,
	"volume_sfx": 1.0,
	"fullscreen": false,
	"controller_vibrations": true,
	"screen_shake": true,
	"language": "en",
	# resolutions (screen size), keyboard config, controller config, accessibility
}
# NOTE : On pourrait faire des gets pour chaque settings ou du moins les plus demander.

@onready var settings = default_settings

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
