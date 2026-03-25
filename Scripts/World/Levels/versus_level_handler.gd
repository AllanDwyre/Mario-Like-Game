extends LevelHandlerBase
class_name VersusLevelHandler

@export var split_screen_handler : SplitScreenHandler
@export var wrap_handler : WrapViewportHandler

var config : VersusSettings
var last_star_pos : Vector2 = Vector2.INF

#region Templates in orders

func _load_config() -> void:
	config = GameManager.consume_config() as VersusSettings
	if config == null :
		assert(OS.is_debug_build(), "VersusLevelHandler attend un VersusSettings")
		_load_debug_config()

func _instanciate_level() -> void:
	var _level = config.chosen_map.scene.instantiate()
	assert(_level is Level)
	level = _level
	$WorldSubViewport.add_child(level)

func _setup_level() -> void:
	PlayerManager.change_players_listen_mode(PlayerInfo.ListenMode.EXCLUSIVE)
	wrap_handler.setup(level.map_info, level.wrap_margin)
	_spawn_one_star()
	SoundManager.play_music(level.level_music)
#endregion

#region Player events
func _create_player(player_id : int, info : PlayerInfo) -> void:
	var viewport = _create_player_viewport(player_id)
	var _view_context = _create_player_ui_context(player_id, viewport)
	#view_context.push(VersusGameplayView)
	_spawn_player(viewport, player_id, info)

func _create_player_viewport(player_id : int) -> SubViewport:
	var viewport := split_screen_handler.create_viewport_for(player_id)
	wrap_handler.generate_viewers(viewport)
	return viewport

func _create_player_ui_context(device_id : int, viewport : SubViewport) -> ViewContext:
	# --- limit player focus only to his viewport ---
	var player_focus_group = FocusGroup.new()
	player_focus_group.device_id = device_id
	viewport.add_child(player_focus_group)
	# --- create player own ui context ---
	var player_ctx = ViewContext.new()
	player_focus_group.add_child(player_ctx)
	ViewManager.register_context(_get_player_ui_context_name(device_id), player_ctx)
	return player_ctx

func _spawn_player(viewport : SubViewport, device_id : int, info : PlayerInfo) -> void:
	var player_instance : Player = PLAYER_PREFAB.instantiate()
	player_instance.name += "_P%d" % info.device_id
	viewport.add_child(player_instance)
	player_instance.setup_player(info)
	player_instance.global_position = _get_spawn_position(device_id)

func _on_player_joined(device_id : int, info : PlayerInfo) -> void:
	if OS.is_debug_build() :
		_create_player(device_id, info)
		return
	push_warning("Player cannot join in middle of the game")

func _on_player_leave(device_id : int) -> void:
	split_screen_handler.remove_viewport_for(device_id)
	_check_win_condition() # cut the party early if only one player left
	# TODO : Update other player gameplay view

func _on_player_connection_lost(device_id : int) -> void :
	var message_scene : PackedScene = load("res://Prefabs/Views/message_overlay_view.tscn")
	var player_info = PlayerManager.get_player_info(device_id)
	for id in PlayerManager.get_all_player_ids():
		var view_ctx =  ViewManager.get_context(_get_player_ui_context_name(id))
		var message_overlay = message_scene.instantiate() as MessageOverlayView
		if id == device_id:
			message_overlay.controller_disconnected()
		else :
			message_overlay.pause_game("caused by Player %d" % player_info.player_id)
		view_ctx.push(message_overlay)

func _on_player_reconnected(_device_id : int) -> void :
	for id in PlayerManager.get_all_player_ids():
		var view_ctx =  ViewManager.get_context(_get_player_ui_context_name(id))
		if view_ctx.active_view is MessageOverlayView:
			view_ctx.pop()

func _on_player_die(player : Player) -> void:
	var player_id := player.player_info.device_id
	var viewport := split_screen_handler.get_player_viewport(player_id)
	_spawn_player.call_deferred(viewport, player_id, player.player_info)
	player.queue_free()
	
#endregion

#region Stars
func _spawn_one_star() -> void:
	var spawns := level.stars_spawns
	assert(not spawns.is_empty(), "Level stars_spawns est vide")
	# --- dont take the same pos of the last star ---
	var pos : Vector2 = last_star_pos
	while pos == last_star_pos:
		pos = spawns.pick_random().global_position
		if spawns.size() < 2: 
			break
	last_star_pos = pos
	# --- instanciate new star ---
	var star := (load("res://Prefabs/World/starman.tscn") as PackedScene).instantiate() as Starman
	$WorldSubViewport.add_child(star)
	star.global_position = pos
	# --- connect to star event ---
	star.star_tooked.connect(_on_star_collected, CONNECT_ONE_SHOT)
	
func _on_star_collected(player_id : int) -> void:
	_add_star_to_player(player_id)
	_check_win_condition()
	
	_reset_level()
	_spawn_one_star.call_deferred()

func _add_star_to_player(_player_id : int):
	pass

#endregion
	
func _reset_level():
	if level.level_tilemap is ResetableTilemap:
		level.level_tilemap.reset_tilemap()

func _check_win_condition() -> void:
	pass
	#config.session.advance_round()
	#if config.session.is_match_over(config):
		#GameManager.go_to_results(config)
	#else:
		#GameManager.go_to_map_selection(config)
#region Helpers

func _get_player_ui_context_name(player_id : int) -> StringName:
	return &"PlayerViewContext_%d" % player_id
	
func _load_debug_config() -> void:
	config = VersusSettings.new()
	config.chosen_map = load("res://Data/MapData/level1.tres")
	PlayerManager.enable_joining(false) # disable keyboard for comfort reason
	GameManager.current_gamemode = GameManager.EGameMode.Versus
	
#endregion
