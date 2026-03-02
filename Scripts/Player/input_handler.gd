extends Node
class_name InputHandler

var player_context : PlayerContext
var info : PlayerInfo

# TODO : add a parameter to process only from one device

func _ready() -> void:
	enable(false)

func set_up(player_context_ : PlayerContext, info_ : PlayerInfo):
	player_context = player_context_
	info = info_
	enable(true)

func enable(active : bool) -> void:
	set_physics_process(active)
	set_process_input(active) 
	set_process(active)
	if player_context :
		player_context.can_move = active

# For instant action that not require continous change (its a event)
func _input(event: InputEvent) -> void:
	if not player_context:
		return
	
	if not info.get_autorisation_from_device(event.device):
		return
	
	_handle_jump(event)
	_handle_run(event)
	_handle_direction(event)


func _handle_jump(event: InputEvent) -> void:
	if event.is_action_pressed("jump"):
		player_context.jump_pressed = true
		player_context.buffered_timer = player_context.player.movement.jump_buffer_duration
	player_context.jump_released = event.is_action_released("jump")

func _handle_run(event: InputEvent) -> void:
	if event.is_action_pressed("run"):
		player_context.run_pressed = true
	elif event.is_action_released("run"):
		player_context.run_pressed = false

func _handle_direction(event: InputEvent) -> void:
	if event.is_action_pressed("left"):
		player_context.direction = -1.0
	elif event.is_action_pressed("right"):
		player_context.direction = 1.0
	
	elif not Input.is_action_pressed("left") and not Input.is_action_pressed("right"):
		player_context.direction = 0.0
