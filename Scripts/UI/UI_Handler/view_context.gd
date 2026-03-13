extends Node
class_name ViewContext

var history: Array[View] = []

var active_view : View:
	get: return null if history.is_empty() else history.back()
	
func _add(v : View):
	add_child(v)
	v.show_view()
	history.push_back(v)

## Permet la premiere insertion, comme lorsque le jeu commence avec le main_menu
func insert_view(v : View):
	if active_view and  v == active_view:
		push_warning("Tried to push the same view as the active one")
		return
	clear_history()
	v.show_view()
	history.push_back(v)

func push(v : View, hide : bool = true):
	if active_view and  v == active_view:
		push_warning("Tried to push the same view as the active one")
		return
	
	if hide and active_view:
		active_view.hide_view()
	_add(v)

func replace_with(v : View):
	pop()
	_add(v)

func pop():
	if history.is_empty(): 
		push_warning("Cannot pop no view to be removed")
		return
	var toRemoved = active_view
	history.pop_back()
	toRemoved.destroy_view()
	# Après suprimer la vue, on reaffiche celle d'avant
	if active_view:
		active_view.show_view()

func pop_until(target : View):
	if not history.has(target):
		push_warning("Cannot pop_until target, target doesnt exist")
		return
	
	while active_view != target:
		pop()

func clear_history():
	while history.size() > 1:
		pop()

func _exit_tree() -> void:
	ViewManager.unregister_context_by_value(self)
