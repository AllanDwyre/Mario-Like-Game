extends LevelHandlerBase
class_name StoryLevelHandler

var config : SoloSettings
const MAPS : Registry = preload("res://Data/map_registry.tres")

func _load_config() -> void:
	config = GameManager.consume_config() as SoloSettings

func _instanciate_level() -> void:
	# A enelever : 
	var valid_maps = MAPS.filter_by_values({
		"ready_prod" : true,
		"versus_map" : false
	})
	config.level = valid_maps.pick_random()
	if config.level == null:
		push_error("no valid map for solo")
		get_tree().quit(4)
		await get_tree().process_frame
		return
	# ------
	var _level = config.level.scene.instantiate()
	assert(_level is Level)
	level = _level
	self.add_child(level)

func _setup_level() -> void:
	SoundManager.play_music(level.level_music)
	_spawn_all_stars()
	
#region Player Connectivity

func _create_player(_player_id : int, _info : PlayerInfo) -> void:
	pass
	
func _on_player_joined(_player_id : int, _info : PlayerInfo) -> void:
	pass

func _on_player_leave(_player_id : int) -> void:
	pass

func _on_player_connection_lost(_player_id : int) -> void:
	pass

func _on_player_reconnected(_player_id : int) -> void:
	pass

func _on_player_die(_player : Player) -> void:
	pass

#endregion

#region Stars
func _spawn_all_stars() -> void:
	pass

func _on_star_collected(_player_id : int) -> void:
	pass
#endregion
