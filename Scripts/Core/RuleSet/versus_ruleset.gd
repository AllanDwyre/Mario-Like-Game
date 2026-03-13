extends RuleSet
class_name VersusRuleSet

func init_level_handler(levelHandler: LevelHandler) -> void:
	assert(levelHandler.config is VersusSettings)
	var config = levelHandler.config
	if config.map_selection_mode == config.ESelectionMode.Random:
		config.level = levelHandler.get_random_file_from_folder("res://Scenes/MultiplayerLevels/")
	levelHandler.instanciate_level()
	# toujours apres instanciate_level :
	var level = levelHandler.level
	levelHandler.wrap_handler.setup(level.map_info, level.wrap_margin)

func on_player_die(player : Player, levelHandler : LevelHandler):
#	TODO : respawn
	levelHandler.respawn(player)
	pass

func on_enemy_die(enemy : EnemyBase):
#	TODO : hide et attend on_star_collected
	pass
#region Star Rules

func star_setup(levelHandler : LevelHandler):
	levelHandler.setup_one_star()

func on_star_collected(player_id : int, levelHandler : LevelHandler):
	levelHandler.versus_star_collected(player_id)
#	TODO : Add le nombre de star collected pour le joueur precis 
#	TODO : Verifie le win condition, reset la map et enemies morts
#endregion

#region Coins Rules

func on_coin_collected(player : Player):
#	TODO : Update le nombre de coin collected par le joueur
#	TODO : si il arrive a un nombre voulu, on appelle on_coin_reward
	pass

func on_coin_reward(to_player : Player):
#	TODO : Donne un powerup aléatoire
	pass
#endregion


func on_entity_spawned(_entity):
#	TODO : Je sais pas ce que ça doit faire
	pass
