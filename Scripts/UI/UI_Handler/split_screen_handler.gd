class_name SplitScreenHandler
extends Node

@onready var grid_container : GridContainer = $GridContainer
@export var world_viewport : SubViewport 

var _player_viewports : Dictionary[int, SubViewport] = {}

# -------------------------------------------------
func _ready() -> void:
	if world_viewport == null:
		printerr("WorldViewport is null, SplitScreenHandler is freed")
		queue_free()

# -------------------------------------------------

func get_player_viewport(player_id: int) -> SubViewport:
	return _player_viewports.get(player_id, null)

# -------------------------------------------------
func create_viewport_for(player_id :int) -> SubViewport:
	if _player_viewports.has(player_id):
		push_warning("Try to create a viewport for a player with already a viewport")
		return null
	
	# --- ViewportContainer ---
	var viewport_container : SubViewportContainer = SubViewportContainer.new()
	viewport_container.name = "viewport_container_P%d" %player_id
	viewport_container.size_flags_vertical = Control.SIZE_EXPAND_FILL
	viewport_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	viewport_container.stretch = true
	
	# --- Viewport ---
	var viewport : SubViewport = SubViewport.new()
	viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	viewport.canvas_item_default_texture_filter = Viewport.DEFAULT_CANVAS_ITEM_TEXTURE_FILTER_NEAREST
	viewport.anisotropic_filtering_level = Viewport.ANISOTROPY_DISABLED

	viewport.disable_3d = true
	viewport.world_2d = world_viewport.world_2d
	viewport.name = "Viewport_P%d" %player_id
	# --- Add to scene ---
	viewport_container.add_child(viewport)
	grid_container.add_child(viewport_container)
	
	_player_viewports[player_id] = viewport
	_update_grid_columns()
	
	return viewport

func remove_viewport_for(player_id: int) -> void:
	if not _player_viewports.has(player_id):
		push_warning("Try to remove viewport for a player that doesnt have a viewport")
		return
	
	_player_viewports[player_id].get_parent().queue_free()
	_player_viewports.erase(player_id)
	_update_grid_columns()

# -------------------------------------------------

func _update_grid_columns() -> void:
	match _player_viewports.size():
		1:    grid_container.columns = 1
		2:    grid_container.columns = 1
		3, 4: grid_container.columns = 2
		_:    grid_container.columns = 3
