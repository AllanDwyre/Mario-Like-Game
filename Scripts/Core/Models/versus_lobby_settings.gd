class_name VersusSettings
extends BaseGameSetting

enum ESelectionMode { Random, Majority, Ban, Host }
enum EMatchType { Tournois, SameParty}


var session : VersusSessionState = VersusSessionState.new()

var stars_to_win : int = 5
## -1 veut dire que la fonctionnalité est désactiver.
## Nombre de vies avant de mourrir
var lives : int = -1
var time_limit : int = -1
var map_selection_mode : ESelectionMode = ESelectionMode.Random
var match_type : EMatchType = EMatchType.SameParty




func desactivate_time_limit() -> void:
	time_limit = -1

func set_time_limit(_min : int) -> void:
	time_limit = _min * 60
