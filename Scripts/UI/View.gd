@abstract
class_name View extends CanvasLayer

signal view_opened()
signal view_closed()

func show_view():
	show()
	view_opened.emit()
	set_process(true)

func hide_view():
	view_closed.emit()
	hide()
	set_process(false)

func destroy_view():
	view_closed.emit()
	_clean_up()
	queue_free()

func _clean_up():
	pass
