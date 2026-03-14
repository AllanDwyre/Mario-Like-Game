@abstract
extends RefCounted
class_name RuleSet

# ALL Events rules

var player_damage_player : bool
 
@abstract
func init_level_handler(levelHandler: LevelHandler) -> void

@abstract
func on_player_die(player : Player, levelHandler : LevelHandler) -> void

@abstract
func on_enemy_die(enemy : EnemyBase) -> void

#region Star Rules
@abstract
func star_setup(levelHandler : LevelHandler) -> void

@abstract
func on_star_collected(player_id : int, levelHandler : LevelHandler) -> void
#endregion

#region Coins Rules
@abstract
func on_coin_collected(player : Player) -> void

@abstract
func on_coin_reward(to_player : Player) -> void
#endregion

@abstract
func on_entity_spawned(entity) -> void
