extends Node

const MAX_PLAYERS := 2
const IS_KEYBOARD_ELIGIBLE = false
var connected_players: Dictionary[int, PlayerInfo] = {}

# --- Signals ---
signal player_joined(device_id: int, player_info: PlayerInfo)
signal player_left(device_id: int)

# -------------------------------------------------
func _ready() -> void:
	# Listen for controller connections/disconnections
	Input.joy_connection_changed.connect(_on_joy_connection_changed)

# -------------------------------------------------
# Call this from your main menu or lobby scene
func enable_joining() -> void:
	print("joining enabled")
	set_process_input(true)

func disable_joining() -> void:
	print("joining disabled")
	set_process_input(false)
# -------------------------------------------------

func _input(event: InputEvent) -> void:
	if is_full():
		return

	# Accept any controller button press or keyboard key
	var device_id := _get_device_from_event(event)
	if device_id == -99:
		return  # Not a join-eligible event

	# Already joined?
	if connected_players.has(device_id):
		return

	_join_player(device_id)

## Auto-remove player if controller is physically disconnected
func _on_joy_connection_changed(device: int, connected: bool) -> void:
	if not connected:
		if connected_players.has(device):
			print("[PlayerManager] Controller %d disconnected." % device)
			leave_player(device)

func leave_player(device_id: int) -> void:
	if not connected_players.has(device_id):
		return
	var player_info: PlayerInfo = connected_players[device_id]
	player_info.on_leave() # handle to propagate the destroying of the player node
	
	connected_players.erase(device_id)
	print("[PlayerManager] Player %d left (device %d)" % [device_id, device_id])
	player_left.emit(device_id) # notify system wide

func _join_player(device_id: int) -> void:
	connected_players[device_id] = PlayerInfo.new(device_id)
	print("[PlayerManager] Player %d joined (device %d)" % [device_id, device_id])
	player_joined.emit(device_id, connected_players[device_id])

#region Helpers
func get_all_player_info() -> Array[PlayerInfo]:
	return connected_players.values()
	
func get_player_info(player_id: int) -> PlayerInfo:
	return connected_players.get(player_id, null)

func get_player_count() -> int:
	return connected_players.size()

func is_full() -> bool:
	return connected_players.size() >= MAX_PLAYERS

func _get_device_from_event(event: InputEvent) -> int:
	# Keyboard: device -1 (player 0 only)
	if event is InputEventKey and event.pressed and not event.echo:
		if not connected_players.has(-1):
			return -1 if IS_KEYBOARD_ELIGIBLE else -99

	# Controller: any button press
	if event is InputEventJoypadButton and event.pressed:
		return event.device

	return -99  # Not eligible
#endregion 
