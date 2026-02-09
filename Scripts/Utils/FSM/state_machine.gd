class_name FiniteStateMachine extends RefCounted

var states : Dictionary = {}
var currentState : State
var initialState : State


func _init(initialState, all_states : Dictionary) -> void:
	for child in all_states:
		if child is State:
			states[child.name.to_lower()] = child
			(child as State).transitionned.connect(change_state)
			
	if initialState: 
		initialState.Enter()
		currentState = initialState


func _process(delta: float) -> void:
	if currentState:
		currentState.Update(delta)


func _physics_process(delta: float) -> void:
	if currentState:
		currentState.Physics_Update(delta)

func change_state(old_state : State, new_state_name : String):
	if old_state != currentState:
		push_warning("Invalid change_state trying from " + old_state.name + " but currently in :" + currentState.name)
		return
	
	var new_state : State = states.get(new_state_name.to_lower())
	if not new_state:
		push_warning("Trying to change to a non-existing state named '" + new_state_name + "'")
		return
	
	if currentState:
		currentState.Exit()
	
	new_state.Enter()
	currentState = new_state
