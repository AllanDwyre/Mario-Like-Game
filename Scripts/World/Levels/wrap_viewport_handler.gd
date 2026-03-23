extends Node
class_name WrapViewportHandler

@export var world_viewport : SubViewport

@onready var viewport_left : SubViewport = $LeftSubViewport
@onready var viewport_right : SubViewport = $RightSubViewport

@onready var camera_left : Camera2D = $LeftSubViewport/Camera2D
@onready var camera_right : Camera2D = $RightSubViewport/Camera2D

var map_info: Dictionary
var margin_px: int
var viewport_height : int

func setup(map_info_ : Dictionary, wrap_margin_ : int):
	print("[WrapViewportHandler] Start Setup")
	map_info = map_info_
	margin_px = wrap_margin_ * 16
	viewport_height = world_viewport.size.y
	
	if not is_node_ready():
		await ready
	
	_setup_viewports()
	_setup_cameras()
	print("[WrapViewportHandler] All Setup")
	
func generate_viewers(node : Node):
	var map_center_y = map_info["start_pos"].y + map_info["height"] / 2.0
	
	var viewer_left = Sprite2D.new()
	viewer_left.global_position = Vector2(map_info["start_pos"].x - margin_px / 2.0, map_center_y)
	viewer_left.texture = viewport_left.get_texture()
	
	var viewer_right = Sprite2D.new()
	viewer_right.global_position = Vector2(map_info["end_pos"].x + margin_px / 2.0, map_center_y)
	viewer_right.texture = viewport_right.get_texture()
	
	node.add_child(viewer_left)
	node.add_child(viewer_right)

func _setup_viewports():
	viewport_left.world_2d = world_viewport.world_2d
	viewport_right.world_2d = world_viewport.world_2d
	# --- Taille des subviewports ---
	# On utilise la taille de la viewport car on veux aussi les nuages etc.. qui ne font pas parti de laa tile du level
	viewport_left.size = Vector2(margin_px, viewport_height)
	viewport_right.size = Vector2(margin_px, viewport_height)

func _setup_cameras():
	print(map_info["start_pos"].x)
	var map_center_y = map_info["start_pos"].y + map_info["height"] / 2.0
	var left_cam_x = map_info["end_pos"].x - margin_px / 2.0
	camera_left.position = Vector2(left_cam_x, map_center_y)
	var right_cam_x = map_info["start_pos"].x + margin_px / 2.0
	camera_right.position = Vector2(right_cam_x, map_center_y)
