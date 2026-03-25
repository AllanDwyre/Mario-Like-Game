extends Node
# --- Autoloads : PlayerManager ---
const MAX_PLAYERS := 4
const KEYBOARD_ID = -1
const NOT_ELIGIBLE = -99
var connected_players: Dictionary[int, PlayerInfo] = {}

var _enable_keyboard = true
var _enable_auto_leave = true
var _current_listen_mode : PlayerInfo.ListenMode = PlayerInfo.ListenMode.KEYBOARD_OR_JOY

# --- Signals ---
signal player_joined(device_id: int, player_info: PlayerInfo)
signal player_left(device_id: int)

signal player_connection_lost(device_id: int)
signal player_reconnected(device_id: int)

# -------------------------------------------------
func _ready() -> void:
	# Listen for controller connections/disconnections
	Input.joy_connection_changed.connect(_on_joy_connection_changed)

# -------------------------------------------------
func enable_auto_leave(auto_leave):
	_enable_auto_leave = auto_leave

func enable_keyboard(enable = true):
	_enable_keyboard = enable
	# --- refresh the keyboard player if he exist ---
	if _enable_keyboard == false and connected_players.has(KEYBOARD_ID):
		var kb_player = connected_players[KEYBOARD_ID]
		var using_controller = kb_player.last_used_device != KEYBOARD_ID
		# --- Si le player utilise autre chose qu'un keyboard on l'assigne a cette autrechose ---
		if using_controller:
			kb_player.device_id = kb_player.last_used_device
			kb_player.listen_mode = PlayerInfo.ListenMode.EXCLUSIVE
			connected_players.erase(KEYBOARD_ID)
			connected_players[kb_player.device_id] = kb_player
		# --- Sinon, on le remove de la liste des participant ---
		else:
			leave_player(KEYBOARD_ID)

# Call this from your main menu or lobby scene
func enable_joining(enable_keyboard_ = true) -> void:
	print("joining enabled")
	set_process_input(true)
	enable_keyboard(enable_keyboard_)

func disable_joining() -> void:
	print("joining disabled")
	set_process_input(false)

func change_players_listen_mode(mode : PlayerInfo.ListenMode):
	_current_listen_mode = mode
	for player in connected_players.values():
		player.listen_mode = mode
# -------------------------------------------------

func _input(event: InputEvent) -> void:
	if is_full():
		return
	
	# Accept any controller button press or keyboard key
	var device_id := _get_device_from_event(event)
	if device_id == NOT_ELIGIBLE:
		return  # Not a join-eligible event
	
	# Already joined?
	if connected_players.has(device_id):
		return
	
	join_player(device_id)

## Auto-remove player if controller is physically disconnected
func _on_joy_connection_changed(device: int, connected: bool) -> void:
	if connected:
		if connected_players.has(device):
			player_reconnected.emit(device)
		return
	# --- si disconnected & known device then :
	print("[PlayerManager] Controller %d disconnected." % device)
	player_connection_lost.emit(device)
	if _enable_auto_leave:
		leave_player(device)
# -------------------------------------------------

func leave_player(device_id: int) -> void:
	if not connected_players.has(device_id):
		return
	var player_info: PlayerInfo = connected_players[device_id]
	player_info.on_leave() # handle to propagate the destroying of the player node
	
	connected_players.erase(device_id)
	print("[PlayerManager] Player %d left (device %d)" % [device_id, device_id])
	player_left.emit(device_id) # notify system wide

func join_player(device_id: int) -> void:
	var player_info = PlayerInfo.new(device_id, _current_listen_mode)
	connected_players[device_id] = player_info
	player_info.set_player_id(get_player_count())
	print("[PlayerManager] Player %d joined (device %d)" % [device_id, device_id])
	player_joined.emit(device_id, connected_players[device_id])
# -------------------------------------------------
#region Helpers
func get_all_player_info() -> Array[PlayerInfo]:
	return connected_players.values()
	
func get_player_info(player_id: int) -> PlayerInfo:
	return connected_players.get(player_id, null)

func get_all_player_ids() -> Array[int]:
	return connected_players.keys()

func get_player_count() -> int:
	return connected_players.size()

func is_full() -> bool:
	return connected_players.size() >= MAX_PLAYERS

func get_host_id() -> int:
	var ids := get_all_player_ids()
	if ids.is_empty():
		return -1
	return ids.min()

func reset() -> void:
	print("Player Manager has been reset")
	for player in get_all_player_ids():
		leave_player(player)

# -------------------------------------------------
func _get_device_from_event(event: InputEvent) -> int:
	if event.is_action_pressed("ui_cancel"):
		return NOT_ELIGIBLE
	
	if event is InputEventKey and event.pressed and not event.echo:
		if _enable_keyboard and not connected_players.has(KEYBOARD_ID):
			return KEYBOARD_ID

	if (event is InputEventJoypadButton and event.pressed) \
			or (event is InputEventJoypadMotion and abs(event.axis_value) > 0.2):
		return event.device

	return NOT_ELIGIBLE
# -------------------------------------------------

#endregion 
