extends  Control
class_name FocusGroup

const DEVICE_ALL = -99

## Joueur assigné à ce groupe (-1 = host/tous, 0..N = joueur spécifique)
@export var device_id: int = DEVICE_ALL
## Permet au host de contrôler ce groupe si le joueur assigné est absent
@export var only_host: bool = false

# ─── état interne ───────────────────────────────────────────────
var _focused_item: Control = null
var _active: bool = false

# ─── Signal ─────────────────────────────────────────────────────
signal focus_changed(old_item: Control, new_item: Control, group: FocusGroup)
signal item_confirmed(item: Control, group: FocusGroup)

# ─── Easy access ────────────────────────────────────────────────
static func get_for(node: Node) -> FocusGroup:
	var n := node.get_parent()
	while n:
		if n is FocusGroup:
			return n as FocusGroup
		n = n.get_parent()
	return null

static func grab_focus_for(node : Control, focus_group : FocusGroup = null) -> void:
	if focus_group == null:
		focus_group = get_for(node)
	if focus_group == null:
		node.grab_focus()
		return
	focus_group._set_focus(node)
# ─── Focus Group Logic ──────────────────────────────────────────

#region Get Interactable Logic
func _init() -> void:
	print(name)

func _ready() -> void:
	await get_tree().process_frame
	_patch_all_interactibles(self)

func _patch_all_interactibles(node: Node) -> void:
	for child in node.get_children():
		if child is FocusGroup:
			continue
		# --- On ne veut pas que le system natif de godot focus sur notre UI ---
		if child is Control and (child as Control).focus_mode != FOCUS_NONE:
			(child as Control).focus_mode = FOCUS_NONE
			if _focused_item == null:
				_focused_item = child as Control
		_patch_all_interactibles(child)

#endregion

#region Focus Handling
func activate(start_item : Control = null) -> void:
	var target := start_item if start_item != null else _focused_item
	_active = true
	if target:
		_set_focus(target)

func desactivate() -> void:
	clear_focus()
	_active = false

func get_focused_item() -> Control:
	return _focused_item

func _set_focus(item : Control) -> void:
	_active = true
	if item == null:
		push_warning("item to focus is null")
		return
	var prev = get_focused_item()
	if prev != null:
		prev.notification(Control.NOTIFICATION_FOCUS_EXIT)
	# assign the focus UI
	_focused_item = item
	_focused_item.notification(Control.NOTIFICATION_FOCUS_ENTER)
	focus_changed.emit(prev, _focused_item, self)

func clear_focus() -> void:
	if _focused_item == null:
		return
	focus_changed.emit(_focused_item, null, self)
	_focused_item.notification(Control.NOTIFICATION_FOCUS_EXIT)
	_focused_item = null

func _confirm_focused() -> void:
	var item := get_focused_item()
	if item == null:
		return
	
	if item is BaseButton:
		item.pressed.emit()
		return
	
	item_confirmed.emit(item, self)
	
#endregion

#region Gestion et filtrage des joueurs
func _unhandled_input(event: InputEvent) -> void:
	if not _active or not belongs_to_player(event) or get_focused_item() == null:
		return
	
	if _handle_direction(event):
		get_viewport().set_input_as_handled()
		return
		
	if event.is_action_pressed("ui_accept"):
		_confirm_focused()
		get_viewport().set_input_as_handled()
		return

func _go_to_neighbor(neighbor_path : NodePath) -> bool:
	if neighbor_path == null or neighbor_path.is_empty():
		return false
	
	var neighbor = get_focused_item().get_node_or_null(neighbor_path)
	if neighbor:
		_set_focus(neighbor)
	return neighbor != null

func _handle_direction(event: InputEvent) -> bool:
	if event.is_action_pressed("ui_up"):
		return _go_to_neighbor(get_focused_item().focus_neighbor_top)
	
	elif event.is_action_pressed("ui_right"):
		return _go_to_neighbor(get_focused_item().focus_neighbor_right)
	
	elif event.is_action_pressed("ui_down"):
		return _go_to_neighbor(get_focused_item().focus_neighbor_bottom)
	
	elif event.is_action_pressed("ui_left"):
		return _go_to_neighbor(get_focused_item().focus_neighbor_left)

	
	elif event.is_action_pressed("ui_focus_next"):
		return _go_to_neighbor(get_focused_item().focus_next)
	
	elif event.is_action_pressed("ui_focus_prev"):
		return _go_to_neighbor(get_focused_item().focus_previous)
	return false
	
func _normalize_device_id(event: InputEvent) -> int:
	if event is InputEventKey or event is InputEventMouse:
		return -1  # convention MultiplayerInput : clavier = -1
	return event.device  # gamepad = device réel

func belongs_to_player(event: InputEvent) -> bool:
	var event_device = _normalize_device_id(event)
	if only_host:
		return event_device == PlayerManager.get_host_id()
	
	if device_id == DEVICE_ALL:
		return event_device in PlayerManager.get_all_player_ids()
	
	return event_device == device_id

#endregion
