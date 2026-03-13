@abstract
extends RefCounted
class_name RuleSet

# ALL Events rules
@warning_ignore("unused_parameter")
func on_player_die(player : Player):
	pass

@warning_ignore("unused_parameter")
func on_enemy_die(enemy : EnemyBase):
	pass

@warning_ignore("unused_parameter")
func on_star_collected(player : Player, level : Level):
	pass

@warning_ignore("unused_parameter")
func on_entity_spawned(entity):
	pass
