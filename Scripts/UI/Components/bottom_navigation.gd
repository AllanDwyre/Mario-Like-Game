@tool
extends MarginContainer
class_name BottomNavigation

signal back_btn_pressed()
signal next_btn_pressed()

@onready var back_btn : Button = %BackButton
@onready var next_btn : Button = %NextButton

## Enable the previous focus to have has next the back button and to the back button this previous_focus
@export var previous_focus : Control

@export var has_next : bool = true :
	set(v) :
		has_next = v
		if not is_node_ready():
			await ready
		if v:
			next_btn.disabled = false
			next_btn.show()
		else:
			next_btn.disabled = true
			next_btn.hide()

func _ready() -> void:
	back_btn.pressed.connect(back_btn_pressed.emit)
	next_btn.pressed.connect(next_btn_pressed.emit)
	
	if previous_focus:
		set_last_element(previous_focus)

func set_last_element(element : Control):
	previous_focus = element
	previous_focus.focus_neighbor_bottom = back_btn.get_path()
	previous_focus.focus_next = back_btn.get_path()
	
	back_btn.focus_neighbor_top = previous_focus.get_path()
	back_btn.focus_previous = previous_focus.get_path()
	
	
	
	
	
