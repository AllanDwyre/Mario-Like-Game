class_name VersusMapChoiceView
extends View
var lobby_setting : VersusSettings

var level_handler : PackedScene = preload("res://Scenes/level_handler.tscn")

#region Life cycle
func show_view():
	super()
	PlayerManager.enable_joining()
	if lobby_setting:
		push_warning("[VersusMapChoiceView] VersusSettings is null, creating default")
		lobby_setting = VersusSettings.new()

func hide_view():
	# NOTE : Hide view ce fait seulement quand il y a un push
	# PlayerManager.disable_joining()
	super()

func clean_up():
	PlayerManager.disable_joining()
	#PlayerManager.player_joined.disconnect(_on_player_joined)
	#PlayerManager.player_left.disconnect(_on_player_left)
#endregion

#func _on_player_joined(player_id : int, player_info : PlayerInfo):
	## Add cursors
	#pass
	#
#func _on_player_left(player_id : int):
	## Add cursors
	#pass

func _on_next_button_pressed() -> void:
	lobby_setting.level = "res://Scenes/MultiplayerLevels/m_level_1.tscn"
	# TODO : Push view to selection and move this logic to the next 'future' step
	if lobby_setting == null:
		push_error("Cannot start versus game, settings are null")
		return
	
	GameManager.start_versus_game(level_handler, lobby_setting)


func _on_back_button_pressed() -> void:
	ViewManager.pop()
