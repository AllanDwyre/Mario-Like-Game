## Will handle the level regeneration, the player spawing, orchestrate 
extends Node
class_name World

@export var debug_level : PackedScene
@export var wrap_handler : WrapViewportHandler
var config : VersusLobbySettings
var level : CircularLevel

func _ready() -> void:
	get_config()
	instanciate_level()
	wrap_handler.setup(level.map_info, level.wrap_margin)

func instanciate_level() -> void:
	if config.map_selection_mode == config.ESelectionMode.Random:
		config.level = get_random_file_from_folder("res://Scenes/MultiplayerLevels/")
	
	var _level = (load(config.level) as PackedScene).instantiate()
	assert(_level is CircularLevel, "{config.level} n'est pas un CircularLevel")
	$WorldSubViewport.add_child(_level)
	level = _level
	level.star_tooked.connect(_on_star_took, ConnectFlags.CONNECT_ONE_SHOT)


func _on_star_took(player_id : int):
	print("player %d took the star !!!" %player_id)
	

func get_config():
	config = GameManager.consume_config()
	if config == null :
		print_debug("[World] config was null, we pass the default config")
		config = VersusLobbySettings.new()
		config.level = debug_level.resource_path
	assert(config is VersusLobbySettings, "The config consumed was not of VersusLobbySettings type")

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
	
#region Public Methods
func get_spawn_position(player_id : int) -> Vector2:
	if level.spawns.size() < player_id:
		print("To many player for the selected level")
		return Vector2.ONE
	return level.spawns[player_id].global_position

func spawn_seamless_worldedge(viewport):
	wrap_handler.generate_viewers(viewport)
#endregion
