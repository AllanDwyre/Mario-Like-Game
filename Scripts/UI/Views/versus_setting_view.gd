class_name VersusSettingView
extends View

@export var map_selection_scene : PackedScene

@onready var stars : EnumButton = %Stars
@onready var lives : EnumButton = %Lives
@onready var time_limit : EnumButton = %TimeLimit
@onready var map_selection : EnumButton = %MapSelection
@onready var match_type : EnumButton = %GameMode

var lobby_setting : VersusSettings

# --- cache view ---
var map_selection_view : VersusMapSelectionView

#region Life cycle

func _ready() -> void:
	%FocusGroup.activate(stars)
	%BottomNavigation.next_btn_pressed.connect(_on_next_button_pressed)
	%BottomNavigation.back_btn_pressed.connect(_on_back_button_pressed)
	lobby_setting = VersusSettings.new()
	subscribes()

func on_show() -> void:
	init_setting_values() 
	
func on_hide() -> void:
	%FocusGroup.desactivate()
	%BottomNavigation.next_btn_pressed.disconnect(_on_next_button_pressed)
	%BottomNavigation.back_btn_pressed.disconnect(_on_back_button_pressed)
	unsubscribes()

func subscribes():
	stars.value_changed.connect(on_stars_value_changed)
	lives.value_changed.connect(on_lives_value_changed)
	time_limit.value_changed.connect(on_time_limit_value_changed)
	map_selection.value_changed.connect(on_map_selection_value_changed)
	match_type.value_changed.connect(on_match_type_value_changed)

func unsubscribes():
	stars.value_changed.disconnect(on_stars_value_changed)
	lives.value_changed.disconnect(on_lives_value_changed)
	time_limit.value_changed.disconnect(on_time_limit_value_changed)
	map_selection.value_changed.disconnect(on_map_selection_value_changed)
	match_type.value_changed.disconnect(on_match_type_value_changed)
	
func init_setting_values() -> void:
	lobby_setting.stars_to_win = stars.get_current_value() as int
	lobby_setting.lives = get_int_or_false(lives.get_current_value())
	lobby_setting.time_limit = get_int_or_false(time_limit.get_current_value())
	set_map_selection_mode(map_selection.get_current_value())
	
	if PlayerManager.get_player_count() < 3:
		match_type.hide()
		lobby_setting.match_type = VersusSettings.EMatchType.SameParty
		%BottomNavigation.set_last_element(map_selection)
	else:
		match_type.show()
		set_match_type(match_type.get_current_value())
		map_selection.focus_neighbor_bottom = match_type.get_path()
		map_selection.focus_next = match_type.get_path()
		%BottomNavigation.set_last_element(match_type)
#endregion

#region Value changed events logic

func on_stars_value_changed(_index: int, value: int) -> void:
	lobby_setting.stars_to_win = value as int

func on_lives_value_changed(_index: int, value: Variant) -> void:
	lobby_setting.lives = value as int

func on_time_limit_value_changed(_index: int, value: Variant) -> void:
	lobby_setting.time_limit = value as int

func on_map_selection_value_changed(_index: int, value: String) -> void:
	set_map_selection_mode(value)

func on_match_type_value_changed(_index: int, value: String) -> void:
	set_match_type(value)
#endregion

#region Navigation Logic
func _on_next_button_pressed() -> void:
	print(lobby_setting.map_selection_mode)
	if lobby_setting.map_selection_mode != VersusSettings.ESelectionMode.Random:
		_go_to_map_selection_view()
	else:
		lobby_setting.chosen_map = _get_random_map()
		GameManager.start_versus_game(lobby_setting)

func _on_back_button_pressed() -> void:
	ViewManager.pop()

func _go_to_map_selection_view():
		_lazzy_get_map_selection_view()
		map_selection_view.lobby_setting = lobby_setting
		ViewManager.push(map_selection_view)
#endregion

#region Helpers
func set_map_selection_mode(mode : String) -> void:
	match mode:
		"Random" : lobby_setting.map_selection_mode = VersusSettings.ESelectionMode.Random
		"Majority" : lobby_setting.map_selection_mode = VersusSettings.ESelectionMode.Majority
		"Ban" : lobby_setting.map_selection_mode = VersusSettings.ESelectionMode.Ban
		"Host" : lobby_setting.map_selection_mode = VersusSettings.ESelectionMode.Host
		_ : push_warning("VersusSettings : Current mode selected for map_selection_mode is Unknown")

func set_match_type(type : String) -> void:
	match type:
		"Tournois" : lobby_setting.match_type = VersusSettings.EMatchType.Tournois
		"Same party" : lobby_setting.match_type = VersusSettings.EMatchType.SameParty
		_ : push_warning("VersusSettings : Current type selected for match_type is Unknown")

func get_int_or_false(value : String):
	if value == "OFF":
		return -1
	return value as int
## Creer le cache si il n'existe pas 
func _lazzy_get_map_selection_view():
	if not map_selection_view: 
		var scene = map_selection_scene.instantiate()
		assert(scene is VersusMapSelectionView, "map_choice_scene is not a VersusMapSelectionView")
		map_selection_view = scene as VersusMapSelectionView

func _get_random_map() -> MapData:
	var maps : Registry = load("res://Data/map_registry.tres")
	return maps.load_entry(maps.get_all_string_ids().pick_random())
#endregion
	
	
