@tool
extends BoxContainer
class_name  EnumButton

enum ValueType { TOGGLE, ENUM, RANGE }
#----------------------------------------------

@onready var label : Label = %Label
@onready var left_btn : Button = %Left
@onready var right_btn : Button = %Right
@onready var value_label : Label = %Value

#----------------------------------------------
@export var label_name: StringName = "Label" :
	set(v):
		label_name = v
		if is_node_ready():
			label.text = v
			if v.is_empty():
				label.hide()
			else:
				label.show()

@export var value_type: ValueType = ValueType.ENUM :
	set(v):
		value_type = v
		current_index = 0
		_refresh_value_label()

@export var wrap_value: bool = true


# Pour TOGGLE et ENUM
@export var options: Array[String] = [] :
	set(v):
		options = v
		current_index = 0
		_refresh_value_label()
#----------------------------------------------

@export_category("Range")
@export var range_min: int = 0 :
	set(v):
		range_min = v
		_refresh_value_label()

@export var range_max: int = 10 :
	set(v):
		range_max = v
		_refresh_value_label()

@export var range_step: int = 1 :
	set(v):
		range_step = v
		_refresh_value_label()

#----------------------------------------------
signal value_changed(index: int, value: Variant)

#----------------------------------------------
var enable: bool = true :
	set(v):
		enable = v
		if is_node_ready():
			left_btn.disabled = not v
			right_btn.disabled = not v


var current_index: int = 0
#----------------------------------------------
const HOLD_DELAY: float = 0.5      # délai avant que le repeat commence
 
# TOGGLE / ENUM : vitesse fixe
const HOLD_REPEAT_FIXED: float = 0.15
 
# RANGE : 3 paliers d'accélération progressive
const RANGE_SLOW_REPEAT:   float = 0.15  # 0.5s → 1.5s de maintien
const RANGE_MEDIUM_REPEAT: float = 0.08  # 1.5s → 3.0s de maintien
const RANGE_FAST_REPEAT:   float = 0.02  # 3.0s+ de maintien
 
const RANGE_THRESHOLD_MEDIUM: float = 1.5  # secondes de maintien total
const RANGE_THRESHOLD_FAST:   float = 3  # secondes de maintien total
#----------------------------------------------
var _hold_direction: int = 0
var _hold_timer: float = 0.0
var _is_holding: bool = false
var _hold_elapsed: float = 0.0   # temps total depuis le début du repeat (après HOLD_DELAY)

#----------------------------------------------
var _is_focused = false
var _focus_group : FocusGroup = null

#----------------------------------------------
func _ready() -> void:
	label.text = label_name
	_refresh_value_label()
	
	focus_entered.connect(_on_focus_entered)
	focus_exited.connect(_on_focus_exited)
	
	left_btn.button_down.connect(_start_hold.bind(-1))
	left_btn.button_up.connect(_stop_hold)
	right_btn.button_down.connect(_start_hold.bind(1))
	right_btn.button_up.connect(_stop_hold)
	
	await get_tree().process_frame
	_focus_group = FocusGroup.get_for(self)

func _exit_tree() -> void:
	if not left_btn.button_down.is_connected(_start_hold):
		return
	left_btn.button_down.disconnect(_start_hold)
	left_btn.button_up.disconnect(_stop_hold)
	right_btn.button_down.disconnect(_start_hold)
	right_btn.button_up.disconnect(_stop_hold)

func _navigate(direction: int) -> void:
	if not enable:
		return
	var max_index := _get_max_index()
	if wrap_value:
		current_index = wrapi(current_index + direction, 0, max_index + 1)
	else:
		current_index = clampi(current_index + direction, 0, max_index)
	_refresh_value_label()
	value_changed.emit(current_index, get_current_value())

func _refresh_value_label() -> void:
	if not is_node_ready():
		return
	match value_type:
		ValueType.TOGGLE:
			# TOGGLE = juste OFF / ON, ignore options
			value_label.text = "ON" if current_index == 1 else "OFF"
		ValueType.ENUM:
			if options.is_empty():
				value_label.text = "-"
			else:
				value_label.text = options[current_index]
		ValueType.RANGE:
			var val: int = range_min + current_index * range_step
			value_label.text = str(val)

func _get_max_index() -> int:
	match value_type:
		ValueType.TOGGLE: return 1
		ValueType.ENUM: return maxi(0, options.size() - 1)
		ValueType.RANGE:
			@warning_ignore("integer_division")
			var snapped_max := range_min + ((range_max - range_min) / range_step) * range_step
			@warning_ignore("integer_division")
			return (snapped_max - range_min) / range_step
	return 0

#region input handling

func _input(event: InputEvent) -> void:
	if not enable:
		return
	if not _is_focused:
		return
	
	if _focus_group and not _focus_group.belongs_to_player(event):
		return
	
	if event.is_action_pressed("ui_left"):
		_start_hold(-1)
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("ui_right"):
		_start_hold(1)
		get_viewport().set_input_as_handled()
	elif event.is_action_released("ui_left") or event.is_action_released("ui_right"):
		_stop_hold()
		get_viewport().set_input_as_handled()

func _get_current_repeat_interval() -> float:
	if value_type != ValueType.RANGE:
		return HOLD_REPEAT_FIXED
	if _hold_elapsed >= RANGE_THRESHOLD_FAST:
		return RANGE_FAST_REPEAT
	elif _hold_elapsed >= RANGE_THRESHOLD_MEDIUM:
		return RANGE_MEDIUM_REPEAT
	else:
		return RANGE_SLOW_REPEAT

func _start_hold(direction: int) -> void:
	if not enable:
		return
	if not _is_focused:
		FocusGroup.grab_focus_for(self, _focus_group)
	_navigate(direction)            # action immédiate au premier appui
	_hold_direction = direction
	_hold_timer = HOLD_DELAY        # attendre avant de commencer le repeat
	_hold_elapsed = 0.0
	_is_holding = true

func _stop_hold() -> void:
	_is_holding = false
	_hold_direction = 0
	_hold_timer = 0.0
	_hold_elapsed = 0.0

func _process(delta: float) -> void:
	if not _is_holding:
		return
	_hold_timer -= delta
	if _hold_timer < HOLD_DELAY:
		_hold_elapsed += delta
	if _hold_timer <= 0.0:
		_navigate(_hold_direction)
		_hold_timer = _get_current_repeat_interval()
#endregion
#----------------------------------------------
#region Public Methods
func get_current_value() -> Variant:
	match value_type:
		ValueType.TOGGLE: return current_index == 1
		ValueType.ENUM: return options[current_index]
		ValueType.RANGE: return range_min + current_index * range_step  # valeur réelle
	push_warning("%s : Failed to get current value", name)
	return 0
func set_index(index: int) -> void:
	var valid_index :int
	match value_type:
		ValueType.TOGGLE: valid_index = index % 2
		ValueType.ENUM: valid_index = clampi(index, 0, options.size() - 1)
		ValueType.RANGE: valid_index = clampi(index, 0, _get_max_index())
	current_index = valid_index
	_refresh_value_label()

func set_index_from_value(value: Variant) -> void:
	match value_type:
		ValueType.TOGGLE:
			# accepte bool ou int
			set_index(1 if value else 0)
		ValueType.ENUM:
			# accepte String ou int
			if value is int:
				set_index(value)
			elif value is String:
				var idx := options.find(value)
				if idx == -1:
					push_warning("%s : value '%s' not found in options" % [name, value])
					return
				set_index(idx)
		ValueType.RANGE:
			if value is float or value is int:
				# Arrondi au step le plus proche, puis clamp dans les bornes valides
				var snapped_value := snappedf(float(value - range_min), float(range_step))
				var idx := int(snapped_value / range_step)
				set_index(idx)

func add_option(option : String) -> bool:
	if value_type != ValueType.ENUM:
		push_warning("tried to add option to a %s [%s]" % [ValueType.keys()[value_type], name])
		return false
	if options.has(option):
		push_warning("[%s] option '%s' already exists" % [name, option])
		return false
	options.append(option)
	return true
#endregion
#----------------------------------------------
#region Events Effects

func _on_focus_entered():
	_is_focused = true
	label.add_theme_color_override("font_color", Color.YELLOW)
	value_label.add_theme_color_override("font_color", Color.YELLOW)
	left_btn.add_theme_color_override("font_color", Color.YELLOW)
	right_btn.add_theme_color_override("font_color", Color.YELLOW)

func _on_focus_exited():
	_is_focused = false
	_stop_hold() # tres important
	label.remove_theme_color_override("font_color")
	value_label.remove_theme_color_override("font_color")
	left_btn.remove_theme_color_override("font_color")
	right_btn.remove_theme_color_override("font_color")
# TODO : zoom in zoom out, whiter button, click sound effect, controller vibration (a little)
#endregion
