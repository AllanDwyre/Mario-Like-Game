extends Camera2D
class_name CameraPlayer

@export var player : Player
@export var snap_distance := 500.0

@export var vertical_offset := 16.0
@export var horizontal_bias := 34.0
@export var max_horizontal_bias := 58.0
@export var horizontal_flip_speed := .8

var current_flip = 1.0

func _process(delta: float) -> void:
	handle_teleportation()
	update_horizontal_flip(delta)
	update_camera_position(delta)

# ----------------------------------------

func handle_teleportation():
	var flat_cam_pos = get_screen_center_position()
	flat_cam_pos.y = 0.0
	
	var distance = flat_cam_pos.distance_to(player.global_position)
	if distance < snap_distance:
		return
	
	print("[CameraPlayer] Player wrap teleported")
	reset_smoothing()
	force_update_scroll()

# ----------------------------------------
func update_horizontal_flip(delta : float):
	# --- Update flip only on movement ---
	if abs(player.velocity.x) < 0.1:
		return
	# --- Update flip ---
	current_flip += sign(player.velocity.x) * horizontal_flip_speed * delta
	current_flip = clampf(current_flip, -1.0, 1.0)

# ----------------------------------------
func update_camera_position(_delta : float):
	var h_bias = current_flip * horizontal_bias
	set_offset(Vector2(h_bias, -vertical_offset))
