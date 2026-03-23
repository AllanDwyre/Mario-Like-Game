extends BoxContainer
class_name CustomTabs

@export var tab_controller : TabContainer
@export var button_group : ButtonGroup
@export var bottom_nav : BottomNavigation

var buttons : Array[BaseButton]
var current_index : int = 0

func _ready() -> void:
	buttons = button_group.get_buttons()
	button_group.pressed.connect(_on_btn_pressed)
	_update_current_tab.call_deferred()
	
	if bottom_nav:
		for container in tab_controller.get_children():
			bottom_nav.set_last_element(_get_last_focusable(container))

func _exit_tree() -> void:
	button_group.pressed.disconnect(_on_btn_pressed)

func _on_btn_pressed(btn : BaseButton):
	_set_current_tab_inactive()
	current_index = buttons.find(btn)
	_update_current_tab()

func _input(event: InputEvent) -> void:
	# --- additionnal custom input for quick tab access ---
	if event is InputEventJoypadButton and event.is_pressed():
		if event.button_index == JoyButton.JOY_BUTTON_LEFT_SHOULDER:
			_direction(-1)
			get_viewport().set_input_as_handled()
		elif event.button_index == JoyButton.JOY_BUTTON_RIGHT_SHOULDER:
			_direction(1)
			get_viewport().set_input_as_handled()


func _direction(dir : int, steps: int = 0) -> void:
	if not tab_controller or steps >= tab_controller.get_tab_count():
		return
	
	var prev_index = current_index
	_set_current_tab_inactive()
	
	current_index = wrapi(current_index + dir, 0, tab_controller.get_tab_count())
	var selected_btn = buttons[current_index]
	if selected_btn.disabled:
		_direction(dir, steps + 1)
		return
		
	
	selected_btn.set_pressed_no_signal(true)
	buttons[prev_index].set_pressed_no_signal(false)
	_update_current_tab()

func _update_current_tab() -> void:
	if not tab_controller:
		return
	tab_controller.current_tab = current_index
	_set_current_tab_active()
	_focus_first_interactable(tab_controller.get_current_tab_control())

func _focus_first_interactable(node: Control) -> bool:
	for child in node.get_children():
		if child is Control:
			if child.focus_mode == Control.FOCUS_NONE:
				if _focus_first_interactable(child):
					return true
			else:
				child.grab_focus()
				return true
	return false
	

func _set_current_tab_inactive():
	buttons[current_index].add_theme_color_override("font_color", Color(1.0, 1.0, 1.0, 0.6))

func _set_current_tab_active(): 
	buttons[current_index].remove_theme_color_override("font_color")

func _get_last_focusable(node: Node) -> Control:
	var children = node.get_children()
	# Parcourt les enfants à l'envers
	for i in range(children.size() - 1, -1, -1):
		var child = children[i]
		# Descend récursivement d'abord
		if child.get_child_count() > 0:
			var result = _get_last_focusable(child)
			if result:
				return result
		# Vérifie si ce noeud est focusable
		if child is Control and child.focus_mode != Control.FOCUS_NONE:
			return child
	return null
	
	
	
	
