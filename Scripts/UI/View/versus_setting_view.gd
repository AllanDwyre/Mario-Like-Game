class_name VersusSettingView
extends View

@export var players_container : Container
@export var map_choice_scene : PackedScene

@export_category("UI Elements")
# TODO: Create better types of ui after the ui is comfirmed, and before doing to much code here*
@export var map_selection_options : OptionButton

var level_handler_scene : PackedScene = preload("res://Scenes/level_handler.tscn")

var players : Dictionary[int, Control] = {}
var lobby_setting : VersusSettings

# --- cache view ---
var map_choice_view : VersusMapChoiceView

#region Life cycle
func _ready() -> void:
	populate_players()

func populate_players() -> void:
	for id in PlayerManager.connected_players.keys():
		_on_player_joined(id, PlayerManager.connected_players[id])

func show_view():
	super()
	
	if not PlayerManager.player_joined.is_connected(_on_player_joined):
		PlayerManager.player_joined.connect(_on_player_joined)
		PlayerManager.player_left.connect(_on_player_left)
	PlayerManager.enable_joining()
	lobby_setting = VersusSettings.new()
	sync_settings()

func hide_view():
	# NOTE : Hide view ce fait seulement quand il y a un push
	# PlayerManager.disable_joining()
	super()

func clean_up():
	PlayerManager.disable_joining()
	PlayerManager.player_joined.disconnect(_on_player_joined)
	PlayerManager.player_left.disconnect(_on_player_left)

#endregion

func sync_settings():
	# sync all the parameters = uis.value
	var map_select_mode_id = map_selection_options.get_selected_id()
	lobby_setting.set_map_selection_mode(map_selection_options.get_item_text(map_select_mode_id))
	pass

func _on_player_joined(player_id : int, _player_info : PlayerInfo):
	if players.has(player_id):
		_on_player_left(player_id)
	
	players[player_id] = Label.new()
	players[player_id].text = "Player P%d" %player_id
	players_container.add_child(players[player_id])
	
func _on_player_left(player_id : int):
	if not players.has(player_id):
		return
	players[player_id].queue_free()
	players.erase(player_id)

#region events
func _on_next_button_pressed() -> void:
	sync_settings()
	if lobby_setting.map_selection_mode != lobby_setting.ESelectionMode.Random:
		if not map_choice_view: # cache view
			var scene = map_choice_scene.instantiate()
			assert(scene is VersusMapChoiceView, "map_choice_scene is not a VersusMapChoiceView")
			map_choice_view = scene as VersusMapChoiceView
		
		map_choice_view.lobby_setting = lobby_setting
		ViewManager.push(map_choice_view)
	else:
		GameManager.start_versus_game(level_handler_scene, lobby_setting)

func _on_back_button_pressed() -> void:
	ViewManager.pop()

#endregion
