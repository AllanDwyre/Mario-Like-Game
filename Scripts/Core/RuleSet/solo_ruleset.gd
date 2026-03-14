extends RuleSet
class_name SoloRuleSet

func _init() -> void:
	player_damage_player = false
	
func init_level_handler(levelHandler: LevelHandler) -> void:
	assert(levelHandler.config is SoloSettings)
	levelHandler.instanciate_level()
	levelHandler.wrap_handler.queue_free()


func on_player_die(player : Player, levelHandler : LevelHandler):
#	TODO : relancer le niveau avec la derniere sauvegarde (drapeau)
	# player.remove_life()  # -1hp
	levelHandler.restart_level(player)
	pass

func on_enemy_die(enemy : EnemyBase):
#	TODO : Queue free lenemie
	pass
#region Star Rules

func star_setup(levelHandler : LevelHandler):
	levelHandler.setup_all_stars()

func on_star_collected(player_id : int, levelHandler : LevelHandler):
	levelHandler.solo_star_collected(player_id)
#	TODO : Add le nombre de star collected. 
#	TODO : Ne pas oublier a la fin du niveau de sauvegarder le nombre
#endregion

#region Coins Rules

func on_coin_collected(player : Player):
#	TODO : Update le nombre de coin collected par le joueur
#	TODO : si il arrive a un nombre voulu, on appelle on_coin_reward
	pass

func on_coin_reward(to_player : Player):
#	TODO : Donne une 1 point de vie
	pass
#endregion


func on_entity_spawned(_entity):
#	TODO : Je sais pas ce que ça doit faire
	pass
