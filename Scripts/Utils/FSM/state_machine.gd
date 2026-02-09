extends RefCounted
class_name FiniteStateMachine 

var currentState : State
var initialState : State


func _init(initialState) -> void:
	if initialState: 
		initialState.Enter()
		currentState = initialState


func Update(delta: float) -> void:
	if currentState:
		var next_state = currentState._internal_update(delta)
		
		if next_state:
			Change_state(next_state)


func Physics_Update(delta: float) -> void:
	if currentState:
		currentState.Physics_Update(delta)

func Change_state(state : State):
	if currentState:
		currentState.Exit()
	
	state.Enter()
	currentState = state
