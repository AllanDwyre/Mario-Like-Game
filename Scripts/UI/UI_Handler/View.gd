@abstract
class_name View extends CanvasLayer

signal view_opened()
signal view_closed()

## Called only when the view is created and in the view manager, or the view became active 
func show_view():
	show()
	await on_show()
	view_opened.emit()
	set_process(true)
	
## Called only when the view manager push another view
func hide_view():
	view_closed.emit()
	await on_hide()
	hide()
	set_process(false)
	
## Called on when the view manager pop this view. (don't call it outside view manager)
func destroy_view():
	view_closed.emit()
	clean_up()
	queue_free()

## Override pour jouer une transition d'entrée (pas besoin de super())
func on_show() -> void:
	await get_tree().process_fram

## Override pour jouer une transition de sortie (pas besoin de super())
func on_hide() -> void:
	await get_tree().process_fram

## Things to do before the queue free, like close transition, clear memory, disconnect event etc...
func clean_up():
	pass
