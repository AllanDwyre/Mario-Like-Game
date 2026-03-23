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
	# --- on normalise pour avoir un index de keyboard toujours différent par rapport au manette et
	var normalised_device = -1 if event is InputEventKey else event.device
	if not info.refresh_device(normalised_device):
		return
	_handle_jump()

func _physics_process(_delta: float) -> void:
	if not info.is_device_valid():
		return
	
	player_context.run_pressed = MultiplayerInput.is_action_pressed(info.last_used_device, "run")
	player_context.direction = MultiplayerInput.get_axis(info.last_used_device, "left", "right")

func _handle_jump() -> void:
	if MultiplayerInput.is_action_just_pressed(info.last_used_device, "jump"):
		player_context.jump_pressed = true
		player_context.buffered_timer = player_context.player.movement.jump_buffer_duration
	player_context.jump_released = MultiplayerInput.is_action_just_released(info.last_used_device, "jump")
