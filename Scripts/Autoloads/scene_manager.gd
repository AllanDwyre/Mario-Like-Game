extends Node
# scene_manager.gd

signal scene_changed

var is_transitioning : bool = false

func change_scene(path : Variant, transition: BaseTransition = InstantTransition.new()):
	assert(path is String or path is PackedScene, 'Path must be a string or PackedScene')
	if is_transitioning:
		push_warning("SceneManager: change_scene called while transitioning")
		return
	
	is_transitioning = true
	
	add_child(transition)
	transition.play_out()
	await transition.finished

	# --- swap la scène ---
	if path is PackedScene:
		path = path.resource_path
	get_tree().change_scene_to_file(path)
	await get_tree().process_frame
	
	transition.play_in()
	await transition.finished
	
	is_transitioning = false
	transition.queue_free()
	scene_changed.emit()


func reload_scene(transition: BaseTransition = InstantTransition.new()) -> void:
	if is_transitioning:
		push_warning("SceneManager: reload_scene called while transitioning")
		return
	
	is_transitioning = true
	
	add_child(transition)
	transition.play_out()
	await transition.finished
	
	get_tree().reload_current_scene()
	await get_tree().process_frame
	
	transition.play_in()
	await transition.finished
	
	is_transitioning = false
	transition.queue_free()
	scene_changed.emit()
