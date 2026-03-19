extends RefCounted
class_name PlayerInfo

var _player_character : CharacterRessource

#====== Solo infos ======
var player_hp = 5
var current_power_up_status

#------------------------------------------------------
enum ListenMode { EXCLUSIVE, KEYBOARD_OR_JOY,  NONE}
var listen_mode : ListenMode

var primary_device_id : int
var last_used_device : int  # mis à jour à chaque input valide
#------------------------------------------------------

signal player_leaved
#------------------------------------------------------

func _init(device_id_ : int, listen_mode_ = ListenMode.KEYBOARD_OR_JOY) -> void:
	primary_device_id = device_id_
	last_used_device = -99
	listen_mode = listen_mode_
	
func on_leave():
	player_leaved.emit()

func is_device_valid() -> bool:
	return refresh_device(last_used_device)

func refresh_device(device : int) -> bool:
	match listen_mode:
		ListenMode.EXCLUSIVE : 
			var valid = primary_device_id == device
			if valid:
				last_used_device = primary_device_id
			return valid
		ListenMode.KEYBOARD_OR_JOY :
			var isJoy = Input.is_joy_known(device)
			var valid =  device == -1 or isJoy
			if valid:
				last_used_device = device
			return valid
		ListenMode.NONE:
			return false
		_ :
			push_warning("Current ListenMode is not reconised")
			return false

func joy_vibration(weak_magnitude: float , strong_magnitude: float, duration: float = 1.0):
	if Settings.get_setting("controller_vibrations"):
		Input.start_joy_vibration(primary_device_id, weak_magnitude, strong_magnitude, duration)

func set_joy_light(color : Color):
	if Input.has_joy_light(primary_device_id) :
		Input.set_joy_light(primary_device_id, color)

func set_player_character(character : CharacterRessource):
	assert(_player_character, "The charcter ressource is null")
	_player_character = character
	set_joy_light(character.character_color)
