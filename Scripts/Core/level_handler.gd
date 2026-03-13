## Will handle the level regeneration, the player spawing, orchestrate 
extends Node
class_name LevelHandler

@export var debug_level : PackedScene
@export var wrap_handler : WrapViewportHandler

var level : Level
var config : BaseGameSetting


func _ready() -> void:
	get_config()
	GameManager.rule_set.init_level_handler(self)
	shared_init()
	suscribe_events()

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

func instanciate_level() -> void:
	for n in $WorldSubViewport.get_children():
		n.queue_free()
	
	var _level = (load(config.level) as PackedScene).instantiate()
	assert(_level is Level, "%s n'est pas un Level" %config.level)
	level = _level
	$WorldSubViewport.add_child(level)

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

#endregion 

#region SplitScreenViewPort Methods
## Appeler depuis SplitScreenViewPort au changement de nombre de joueur
func get_spawn_position(player_id : int) -> Vector2:
	if level.player_spawns.size() < player_id:
		print("To many player for the selected level")
		return Vector2.ONE
	return level.player_spawns[player_id].global_position

## Appeler depuis SplitScreenViewPort au changement de nombre de joueur 
func spawn_seamless_worldedge(viewport):
	if GameManager.current_gamemode == GameManager.EGameMode.Versus:
		wrap_handler.generate_viewers(viewport)
#endregion

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

#region On Player Died Methods
func on_player_die(player : Player) -> void:
	GameManager.rule_set.on_player_die(player, self)

func respawn(player : Player) -> void:
	var respawn_pos = get_spawn_position(player.player_info.device_id)
	
func restart_level(player : Player) -> void:
	instanciate_level()
#endregion
