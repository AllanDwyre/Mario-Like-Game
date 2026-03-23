@tool
extends BoxContainer
class_name Prompt

@onready var before_label : Label = %BeforeLabel
@onready var after_label : Label = %AfterLabel
@onready var iconResizer : MarginContainer = %IconResizer
@onready var icon_rect : TextureRect = %Icon

# ----------------------------------------------------------

@export var before : String = "":
	set(v):
		if not is_node_ready():
			await ready
		before = v
		before_label.text = v

@export var after : String = "after":
	set(v):
		if not is_node_ready():
			await ready
		after = v
		after_label.text = v

@export var icon_size : int = 32:
	set(v):
		if not is_node_ready():
			await ready
		icon_size = v
		if not icon:
			return
		var texture_size = icon.get_height()
		var delta_size = max(0, texture_size - icon_size)
		iconResizer.add_theme_constant_override("margin_top", delta_size / 2.0)
		iconResizer.add_theme_constant_override("margin_bottom", delta_size / 2.0)

@export var icon : Texture2D :
	set(v):
		if not is_node_ready():
			await ready
		icon = v
		icon_rect.texture = v
