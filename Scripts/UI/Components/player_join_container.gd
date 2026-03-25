extends  Control
class_name PlayerJoinContainer

@onready var _focus_group : FocusGroup = %FocusGroup

signal ready_value_changed(new_value : bool)

var player_info : PlayerInfo
var _device_input : DeviceInput
var _is_ready : bool = false
var is_active : bool = false

var device_id : int : 
	get:
		if player_info == null:
			return -999  # valeur impossible = aucun device
		return player_info.device_id

func setup(player_info_ : PlayerInfo):
	player_info = player_info_
	_device_input = DeviceInput.new(player_info.device_id)
	_activate.call_deferred()
	
func _activate():
	%FocusGroup.device_id = player_info.device_id
	%DeviceType.text = "%s %d" % [_device_input.get_name(), player_info.device_id + 1]
	%PlayerName.text = "Player %d" % player_info.player_id
	%FocusGroup.activate()
	is_active = true

func reset():
	player_info = null
	_device_input = null
	is_active = false
	_set_ready(false)
	%FocusGroup.device_id = %FocusGroup.DEVICE_ALL
	%FocusGroup.desactivate()

func rename_player(new_id : int):
	player_info.set_player_id(new_id)
	%PlayerName.text = "Player %d" %new_id

func toggle_ready():
	_set_ready(!_is_ready)
	
func _set_ready(value : bool) -> void:
	if value == _is_ready:
		return
	_is_ready = value
	%ReadyPrompt.after = "Ready !" if _is_ready else "Ready ?"
	ready_value_changed.emit(_is_ready)

func _input(event: InputEvent) -> void:
	if not event is InputEventKey and not event is InputEventJoypadButton:
		return  # ignore souris etc pour ne pas spam

	if not is_active or not _focus_group.belongs_to_player(event):
		return
	# --- Player related action ---
	if event.is_action_pressed("ui_accept"):
		toggle_ready()
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("ui_cancel"):
		PlayerManager.leave_player(device_id)
		get_viewport().set_input_as_handled()
