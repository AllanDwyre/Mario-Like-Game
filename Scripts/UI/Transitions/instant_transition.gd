class_name InstantTransition
extends BaseTransition

func play_out() -> void:
	await get_tree().process_frame
	finished.emit()

func play_in() -> void:
	await get_tree().process_frame
	finished.emit()
