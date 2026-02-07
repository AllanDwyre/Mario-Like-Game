extends Node

@export var background_color: Color = Color.SKY_BLUE

func _ready():
	RenderingServer.set_default_clear_color(background_color)
