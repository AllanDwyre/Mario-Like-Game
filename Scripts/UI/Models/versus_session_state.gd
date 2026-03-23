class_name VersusSessionState
extends RefCounted

var wins : Dictionary[int, int] = {}        # device_id → nb de wins
var played_maps : Array[MapData] = []       # maps déjà jouées ce match
var current_round : int = 1

func add_win(device_id : int) -> void:
	wins[device_id] = wins.get(device_id, 0) + 1

func register_played_map(map : MapData) -> void:
	played_maps.append(map)

func has_played(map : MapData) -> bool:
	return map in played_maps

func get_winner() -> int:
	# retourne le device_id du joueur en tête, -1 si aucun
	var max_wins := 0
	var winner := -1
	for id in wins.keys():
		if wins[id] > max_wins:
			max_wins = wins[id]
			winner = id
	return winner
