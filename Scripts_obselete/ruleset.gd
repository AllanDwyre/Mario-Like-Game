@abstract
extends RefCounted
class_name RuleSet

var player_damage_player : bool

@abstract
func init_level_handler(levelHandler: LevelHandler) -> void
@abstract
func on_player_die(player : Player, levelHandler : LevelHandler)
@abstract
func on_enemy_die(enemy : EnemyBase)

#region Star Rules
@abstract
func star_setup(levelHandler : LevelHandler)
@abstract
func on_star_collected(player_id : int, levelHandler : LevelHandler)
#endregion

#region Coins Rules

@abstract
func on_coin_collected(player : Player)

@abstract
func on_coin_reward(to_player : Player)
#endregion


@abstract
func on_entity_spawned(_entity)
