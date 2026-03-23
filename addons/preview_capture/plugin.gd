@tool
extends EditorPlugin

var capture_window: Window

func _enter_tree():
	# Bouton dans le menu Editor
	add_tool_menu_item("📸 Map Preview Capture", _toggle_window)

	# Fenêtre flottante
	capture_window = Window.new()
	capture_window.title = "Map Preview Capture"
	capture_window.size = Vector2i(420, 650)
	capture_window.hide()
	capture_window.close_requested.connect(_toggle_window)

	var dock = preload("res://addons/preview_capture/capture_dock.tscn").instantiate()
	capture_window.add_child(dock)
	EditorInterface.get_base_control().add_child(capture_window)

func _toggle_window():
	if capture_window.visible:
		capture_window.hide()
	else:
		capture_window.popup_centered()

func _exit_tree():
	remove_tool_menu_item("📸 Map Preview Capture")
	capture_window.free()
