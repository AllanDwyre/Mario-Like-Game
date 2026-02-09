extends Node

var is_transitioning: bool = false
var history: Array[View] = []

var active_view : View:
	get: return null if history.is_empty() else history.back()

func _safe_guard(callback : Callable):
	if is_transitioning:
		return
	is_transitioning = true
	callback.call()
	await get_tree().create_timer(0.1).timeout
	is_transitioning = false

func _add(v : View):
	add_child(v)
	v.show_view()
	history.push_back(v)

func push(v : View, hide : bool = true):
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
