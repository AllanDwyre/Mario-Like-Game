extends View
class_name MessageOverlayView

@onready var message_label : Label = %MessageLabel
@export var upper_bands : Array[ColorRect]
@export var bellow_bands : Array[ColorRect]

## 0 - info
## 1 - succeed
## 2 - warning
## 3 - error
@export var defined_colors : ColorPalette

func set_band_color(color : Color):
	for b in upper_bands:
		b.color = color
	for b in bellow_bands:
		b.color = color.darkened(0.2)

func custom_message(message : String, band_color : Color) -> void :
	message_label.text = message
	set_band_color(band_color)

#region Presets

func pause_game(reason : String = "") -> void :
	set_band_color(defined_colors.colors[0])
	var message = "Paused"
	if not reason.is_empty():
		message += " %s" %reason
	message_label.text = message

func controller_disconnected() -> void :
	set_band_color(defined_colors.colors[2])
	message_label.text = "Reconnect your controller"

#endregion
