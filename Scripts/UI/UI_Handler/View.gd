@abstract
class_name View extends CanvasLayer

signal view_opened()
signal view_closed()

## Called only when the view is created and in the view manager, or the view became active 
func show_view():
	show()
	view_opened.emit()
	set_process(true)
	
## Called only when the view manager push another view
func hide_view():
	view_closed.emit()
	hide()
	set_process(false)
	
## Called on when the view manager pop this view. (don't call it outside view manager)
func destroy_view():
	view_closed.emit()
	clean_up()
	queue_free()

## Things to do before the queue free, like close transition, clear memory, disconnect event etc...
func clean_up():
	pass
