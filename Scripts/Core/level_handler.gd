## Will handle the level regeneration, the player spawing, orchestrate 
extends Node
class_name LevelHandler

const PlayerPrefab = preload("res://Prefabs/player.tscn")

@export var debug_level : PackedScene
@export var split_screen_handler : SplitScreenHandler
@export var wrap_handler : WrapViewportHandler
# -------------------------------------------------

var level : Level
var config : BaseGameSetting

# -------------------------------------------------

func _ready() -> void:
	get_config()
	GameManager.rule_set.init_level_handler(self)
	shared_init()
	suscribe_events()

func _exit_tree() -> void:
	GameSignals.player_died.disconnect(on_player_die)
	
	if PlayerManager.player_joined.is_connected(on_player_joined):
		PlayerManager.player_joined.disconnect(on_player_joined)
		PlayerManager.player_left.disconnect(on_player_leave)
# -------------------------------------------------

#region Configuration
func get_config():
	config = GameManager.consume_config()
	if config == null :
		print_debug("[World] config was null, we pass the default config")
		config = SoloSettings.new()
		config.level = debug_level.resource_path
	assert(config is BaseGameSetting, "The config consumed was not of BaseGameSetting (versus or solo) type")

func shared_init():
	GameManager.rule_set.star_setup(self)
	SoundManager.play_music(level.level_music)
	init_players()

func instanciate_level() -> void:
	for n in $WorldSubViewport.get_children():
		n.queue_free()
	
	var _level = (load(config.level) as PackedScene).instantiate()
	assert(_level is Level, "%s n'est pas un Level" %config.level)
	level = _level
	$WorldSubViewport.add_child(level)

# TODO : Change to registry of ressources (able to level name, preview image, sound, ect, ui color)
func get_random_file_from_folder(path: String) -> String:
	var dir := DirAccess.open(path)
	if not dir:
		push_error("Cannot open directory: " + path)
		return ""
	
	var files : Array[String] = []
	dir.list_dir_begin()
	var file_name := dir.get_next()
	while file_name != "":
		if not dir.current_is_dir():
			files.append(file_name)
		file_name = dir.get_next()
	dir.list_dir_end()
	
	if files.is_empty():
		return ""
	
	return path + "/" + files[randi() % files.size()]

func suscribe_events():
	GameSignals.player_died.connect(on_player_die)
	
	PlayerManager.player_joined.connect(on_player_joined)
	PlayerManager.player_left.connect(on_player_leave)

#endregion 
# -------------------------------------------------

#region STAR LOGIC
var last_star_pos : Vector2 = Vector2.INF
signal star_tooked(player_id : int)

func setup_all_stars():
	var stars_spawns = level.stars_spawns
	assert(not stars_spawns.is_empty(), "Level stars_spawns est vide")
	var star_scn = load("res://Prefabs/World/starman.tscn") as PackedScene
	for star_spawn in stars_spawns:
		var star = star_scn.instantiate() as Starman
		star.star_tooked.connect(on_star_took, CONNECT_ONE_SHOT)
		star.global_position = star_spawn.global_position
		add_child.call_deferred(star)

func setup_one_star():
	var stars_spawns = level.stars_spawns
	assert(not stars_spawns.is_empty(), "Level stars_spawns est vide")
	var star_pos = Vector2.INF
	while last_star_pos == star_pos :
		star_pos = stars_spawns.pick_random().global_position
		if stars_spawns.size() < 2 :
			break
	
	var star_scn = load("res://Prefabs/World/starman.tscn") as PackedScene
	var star = star_scn.instantiate() as Starman
	star.star_tooked.connect(on_star_took, CONNECT_ONE_SHOT)
	star.global_position = star_pos
	add_child.call_deferred(star)

func on_star_took(player_id : int):
	GameManager.rule_set.on_star_collected(player_id, self)

func versus_star_collected(player_id : int):
	setup_one_star()
	star_tooked.emit(player_id)
	if level.level_tilemap is ResetableTilemap :
		level.level_tilemap.reset_tilemap()

func solo_star_collected(player_id : int):
	star_tooked.emit(player_id)
#endregion
# -------------------------------------------------
#region player connectivity logic

func init_players():
	for player_id in PlayerManager.get_all_player_ids():
		_create_split_view(player_id)

func on_player_joined(player_id : int, _player_info : PlayerInfo) -> void:
	_create_split_view(player_id)

# TODO : Reflechir sur la façon de gérer une leave en milieu de parti versus
# TODO : peut etre différencier une leave et un disconnect (peut etre invonlontaire)
func on_player_leave(player_id : int) -> void:
	split_screen_handler.remove_viewport_for(player_id)

func _create_split_view(player_id : int) -> void:
	var viewport : SubViewport = split_screen_handler.create_viewport_for(player_id)
	_spawn_player(viewport, player_id)
	_spawn_seamless_worldedge(viewport)

# TODO : use ruleset to create different ways to spawn based on gamemode
# TODO : (solo next to the current player, versus : to the default spawner)
func _spawn_player(viewport : SubViewport, player_id) -> void:
	var player_info : PlayerInfo = PlayerManager.get_player_info(player_id)
	var player_instance : Player = PlayerPrefab.instantiate()
	player_instance.name += "_P%d" %player_id
	# --- Add to the scene to be ready ---
	viewport.add_child(player_instance)
	# --- after being ready we can setup it without null value ---
	player_instance.setup_player(player_info)
	player_instance.global_position = _get_spawn_position(player_id)

func _get_spawn_position(player_id : int) -> Vector2:
	if level.player_spawns.size() < player_id:
		push_warning("To many player for the selected level")
		return Vector2.ZERO
	return level.player_spawns[player_id].global_position

func _spawn_seamless_worldedge(viewport):
	if GameManager.current_gamemode == GameManager.EGameMode.Versus:
		wrap_handler.generate_viewers(viewport)

#endregion
# -------------------------------------------------
#region On Player Died Methods
func on_player_die(player : Player) -> void:
	GameManager.rule_set.on_player_die(player, self)

func respawn(player : Player) -> void:
	var player_id = player.player_info.device_id
	var viewport = split_screen_handler.get_player_viewport(player_id)
	player.queue_free()
	_spawn_player.call_deferred(viewport, player_id)
	
	
func restart_level(player : Player) -> void:
	instanciate_level()
	respawn(player)
#endregion
# -------------------------------------------------
