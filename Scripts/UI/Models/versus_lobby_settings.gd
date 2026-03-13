class_name VersusSettings
extends BaseGameSetting

enum ESelectionMode {
	Random,
	Majority,
	Ban,
}

enum EMatchType {
	Tournois,
	SameParty,
}

var stars_to_win : int = 5
## -1 veut dire que la fonctionnalité est désactiver.
## Nombre de vies avant de mourrir
var lives : int = -1
var time_limit : int = -1
var map_selection_mode : ESelectionMode = ESelectionMode.Random
var match_type : EMatchType = EMatchType.SameParty


func add_player() -> void:
	pass

func remove_player() -> void:
	pass

func desactivate_time_limit() -> void:
	time_limit = -1

func set_time_limit(_min : int) -> void:
	time_limit = _min * 60

func set_map_selection_mode(mode : String) -> void:
	match mode:
		"Random" : map_selection_mode = ESelectionMode.Random
		"Majority Pick" : map_selection_mode = ESelectionMode.Majority
		"Ban System" : map_selection_mode = ESelectionMode.Ban
		_ : push_warning("VersusSettings : Current mode selected for map_selection_mode is Unknown")

func set_match_type(type : String) -> void:
	match type:
		"Tournois" : match_type = EMatchType.Tournois
		"Same party" : match_type = EMatchType.SameParty
		_ : push_warning("VersusSettings : Current type selected for match_type is Unknown")
