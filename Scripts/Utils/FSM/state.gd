@abstract
class_name State extends RefCounted

func Enter():
	pass

func Exit():
	pass

func _internal_update(_delta : float) -> State:
	var next_state = GetTransition()
	if next_state:
		return next_state
		
	Update(_delta)
	return null

func Update(_delta : float):
	pass

func Physics_Update( _delta : float):
	pass

## Return null if we want to stay in the state. Or return the next state to transition to.
func GetTransition() -> State:
	return null
