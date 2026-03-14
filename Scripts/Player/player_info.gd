extends RefCounted
class_name PlayerInfo

var device_id = -1
var _allow_all_device = false
var _player_color : Color
# TODO : add player name, appareances, (?current_win_streak), player solo life left
signal player_leaved


func _init(device_id_ : int, allow_all_device_ = false) -> void:
	device_id = device_id_
	_allow_all_device = allow_all_device_
	set_player_color(Color.WHITE) # by default all white
	
func on_leave():
	player_leaved.emit()

func get_autorisation_from_device(device : int) -> bool:
	return _allow_all_device or device_id == device

func joy_vibration(weak_magnitude: float , strong_magnitude: float, duration: float = 1.0):
	if Settings.get_setting("controller_vibrations"):
		Input.start_joy_vibration(device_id, weak_magnitude, strong_magnitude, duration)

func set_joy_light(color : Color):
	if Input.has_joy_light(device_id) :
		Input.set_joy_light(device_id, color)

func set_player_color(color : Color, force_reset : bool = true):
	_player_color = color
	if force_reset :
		set_joy_light(color)
