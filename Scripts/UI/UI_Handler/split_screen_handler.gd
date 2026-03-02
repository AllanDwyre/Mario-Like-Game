extends Node

const PlayerPrefab : PackedScene = preload("res://Prefabs/player.tscn")
@export var world_viewport : SubViewport 
@export var word : World 
@export var split_strategy : ESplitStrategy = ESplitStrategy.HorizontalSplit

var split_container : SplitContainer

# -------------------------------------------------

enum ESplitStrategy {
	VerticalSplit,
	HorizontalSplit,
}
# -------------------------------------------------

func _ready() -> void:
	if word == null:
		printerr("Level is null, SplitScreenHandler is freed")
		queue_free()
	
	if not word.is_node_ready():
		await word.ready
	
	if world_viewport == null:
		printerr("WorldViewport is null, SplitScreenHandler is freed")
		queue_free()
		
	setup_split_container()
	setup_viewports()
	
	#temporary, (remove when will have a lobby screen)
	PlayerManager.player_joined.connect(func(_device_id: int, _player_info: PlayerInfo) : setup_viewports())
	PlayerManager.player_left.connect(func(_device_id: int) : setup_viewports())

# -------------------------------------------------

func setup_viewports() -> void:
	_clear_viewports()
	for i in range(PlayerManager.get_player_count()):
		var viewport = _create_viewport(i)
		spawn_player(viewport, i)
		word.spawn_seamless_worldedge(viewport)

# -------------------------------------------------
func _create_viewport(viewport_id :int) -> SubViewport:
	# --- ViewportContainer ---
	var viewport_container : SubViewportContainer = SubViewportContainer.new()
	viewport_container.size_flags_vertical = Control.SIZE_EXPAND_FILL
	viewport_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	viewport_container.name = "viewport_container_P%d" %viewport_id
	viewport_container.stretch = true
	# --- Viewport ---
	var viewport : SubViewport = SubViewport.new()
	viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	viewport.canvas_item_default_texture_filter = Viewport.DEFAULT_CANVAS_ITEM_TEXTURE_FILTER_NEAREST
	viewport.anisotropic_filtering_level = Viewport.ANISOTROPY_DISABLED

	viewport.disable_3d = true
	viewport.world_2d = world_viewport.world_2d
	viewport.name = "Viewport_P%d" %viewport_id
	# --- Add to scene ---
	split_container.add_child(viewport_container)
	viewport_container.add_child(viewport)

	return viewport
func _clear_viewports():
	for c in split_container.get_children():
		c.queue_free() 

# -------------------------------------------------

func spawn_player(viewport : SubViewport, player_id) -> void:
	var player_info : PlayerInfo = PlayerManager.get_player_info(player_id)
	var player_instance : Player = PlayerPrefab.instantiate()
	player_instance.name += "_P%d" %player_id
	# --- Add to the scene to be ready ---
	viewport.add_child(player_instance)
	# --- after being ready we can setup it without null value ---
	player_instance.setup_player(player_info)
	player_instance.global_position = word.get_spawn_position(player_id)

# -------------------------------------------------

func setup_split_container() -> void:
	match split_strategy:
		ESplitStrategy.VerticalSplit:
			split_container = VSplitContainer.new()
		ESplitStrategy.HorizontalSplit:
			split_container = HSplitContainer.new()
	
	split_container.set_anchors_preset(Control.PRESET_FULL_RECT)
	split_container.set_deferred("size", get_viewport().get_visible_rect().size)
	add_child(split_container)
