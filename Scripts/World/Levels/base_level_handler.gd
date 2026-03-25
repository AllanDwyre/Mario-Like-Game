@abstract
extends Node
class_name LevelHandlerBase

const PLAYER_PREFAB = preload("res://Prefabs/player.tscn")

var level : Level

# -------------------------------------------------
# Template : ordre fixe, étapes surchargées par les enfants
# -------------------------------------------------
func _ready() -> void:
	_load_config()
	_instanciate_level()
	_setup_level()
	_init_players()
	_subscribe_events()

func _exit_tree() -> void:
	_unsubscribe_events()

# -------------------------------------------------
#region Template steps
@abstract func _load_config() -> void
@abstract func _instanciate_level() -> void
## Useful if we need to setup at initiation time : cams, level, components like warps or dynamic items like stars or other features 
@abstract func _setup_level() -> void       # wrap, musique, caméra, stars...
#endregion

# -------------------------------------------------
#region Shared — même logique pour tous les modes

func _init_players() -> void:
	for player_id in PlayerManager.get_all_player_ids():
		_create_player(player_id, PlayerManager.get_player_info(player_id))

func _subscribe_events() -> void:
	GameSignals.player_died.connect(_on_player_die)
	PlayerManager.player_joined.connect(_on_player_joined)
	PlayerManager.player_left.connect(_on_player_leave)
	PlayerManager.player_reconnected.connect(_on_player_reconnected)
	PlayerManager.player_connection_lost.connect(_on_player_connection_lost)

func _unsubscribe_events() -> void:
	GameSignals.player_died.disconnect(_on_player_die)
	if PlayerManager.player_joined.is_connected(_on_player_joined):
		PlayerManager.player_joined.disconnect(_on_player_joined)
		PlayerManager.player_left.disconnect(_on_player_leave)
		PlayerManager.player_reconnected.disconnect(_on_player_reconnected)
		PlayerManager.player_connection_lost.disconnect(_on_player_connection_lost)
	
func _get_spawn_position(player_id : int) -> Vector2:
	if level.player_spawns.size() <= player_id:
		push_warning("Too many players for this level")
		return Vector2.ZERO
	return level.player_spawns[player_id].global_position
#endregion

# -------------------------------------------------
#region Abstract — comportement propre à chaque mode
## Called at the initiation phase of the game : _init_players()
@abstract func _create_player(player_id : int, info : PlayerInfo) -> void
## Called in the middle of the game. It's used for debugging purposes
@abstract func _on_player_joined(player_id : int, info : PlayerInfo) -> void
## Called in the middle of the game. It's useful to update the state of the game
@abstract func _on_player_leave(player_id : int) -> void
## Called when a player disconnect via device lost (to handle battery controller lost or remote play together lost)
@abstract func _on_player_connection_lost(player_id : int) -> void
## Called when a player was disconnected but reconnected
@abstract func _on_player_reconnected(player_id : int) -> void
## Called when the player died
@abstract func _on_player_die(player : Player) -> void
#endregion
