class_name GameSettingView
extends View


@onready var bottom_nav : BottomNavigation = %BottomNavigation

@onready var general : EnumButton = %GeneralSlider
@onready var music : EnumButton = %MusicSlider
@onready var sfx : EnumButton = %SFXSlider
@onready var controller_vibrations : EnumButton = %ControllerVibrations
@onready var fullscreen : EnumButton = %Fullscreen
@onready var resolution : EnumButton = %Resolution

var _resolutions : Dictionary[StringName, Vector2i]

func show_view():
	super()
	bottom_nav.back_btn_pressed.connect(_on_back_button_pressed, ConnectFlags.CONNECT_ONE_SHOT)


func _ready() -> void:
	_resolutions = ResolutionUtil.retrieve_possible_resolutions()
	
	music.set_index_from_value(Settings.get_volume_music() * 100)
	sfx.set_index_from_value(Settings.get_volume_sfx() * 100)
	controller_vibrations.set_index_from_value(Settings.is_controller_vibration_enabled())
	fullscreen.set_index_from_value(Settings.is_fullscreen())
	#resolution.options = _resolutions.keys()
#	resolution.set_index_from_value(Settings.get_resolution())
	_subscribe()

func _on_back_button_pressed() -> void:
	# rajouter des element comment la transition (pas forcement la)
	ViewManager.pop()

func _subscribe():
	music.value_changed.connect(_on_music_value_changed)
	sfx.value_changed.connect(_on_sfx_value_changed)
	# ---
	fullscreen.value_changed.connect(_on_fullscreen_value_changed)
	# ---
	controller_vibrations.value_changed.connect(_on_controller_vibrations_value_changed)
	
func _exit_tree() -> void:
	if not music.value_changed.is_connected(_on_music_value_changed):
		return
	
	music.value_changed.disconnect(_on_music_value_changed)
	sfx.value_changed.disconnect(_on_sfx_value_changed)
	# ---
	fullscreen.value_changed.disconnect(_on_fullscreen_value_changed)
	# ---
	controller_vibrations.value_changed.disconnect(_on_controller_vibrations_value_changed)
#region Audio
func _on_music_value_changed(_index : int, value: int) -> void:
	Settings.set_volume_music(value / 100.0)

func _on_sfx_value_changed(_index : int, value: int) -> void:
	Settings.set_volume_sfx(value / 100.0)

#endregion
#region Display
func _on_fullscreen_value_changed(_index : int, value: bool) -> void:
	Settings.set_fullscreen(value)

#resolution
#endregion

#region Game
func _on_controller_vibrations_value_changed(_index : int, value: bool) -> void:
	Settings.set_controller_vibration(value)

#endregion

#func _on_resolution_button_item_selected(index: int) -> void:
	#var res = _resolutions.get(resolution_btn.get_item_text(index), Vector2i(1152, 648))
	#Settings.set_setting(RESOLUTION_SETTING, res)
	#get_window().size = res
	#if Settings.get_setting(FULLSCREEN_SETTING) == DisplayServer.WINDOW_MODE_FULLSCREEN:
		#get_window().content_scale_size = res
	#else:
		#var screen_size = DisplayServer.screen_get_size()
		#get_window().position = (screen_size - res) / 2
