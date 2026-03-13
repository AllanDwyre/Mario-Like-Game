extends Node
class_name Level

static var _current : Level
static func get_current_level(): return _current

@export_category("Spawners")
@export var player_spawns_root : Node
@export var stars_spawns_root : Node

@export_category("Wrap Setting")
@export var level_tilemap : TileMapLayer
@export var wrap_margin : int = 20

@export_category("Environnement")
@export var background_color: Color = Color.SKY_BLUE
@export var level_music : AudioStream

var player_spawns : Array[Marker2D]
var stars_spawns : Array[Marker2D]

var map_info = {
	"height" : 0,
	"width" : 0,
	"start_pos" : Vector2.ZERO,
	"end_pos" : Vector2.ZERO,
}

func _ready() -> void:
	_current = self
	player_spawns = _collect_markers(player_spawns_root)
	stars_spawns = _collect_markers(stars_spawns_root)
	setup_map_info()

func _collect_markers(root: Node) -> Array[Marker2D]:
	var result : Array[Marker2D] = []
	if root == null:
		push_warning("Spawner root node manquant")
		return result
	for child in root.get_children():
		if child is Marker2D:
			result.append(child)
	return result

func setup_map_info():
	var rect: Rect2i = level_tilemap.get_used_rect()
	var tile_size: Vector2i = level_tilemap.tile_set.tile_size
	
	# Taille en pixels
	map_info["width"]  = rect.size.x * tile_size.x
	map_info["height"] = rect.size.y * tile_size.y
	
	# Position monde (coin haut-gauche)
	var tile_origin = level_tilemap.map_to_local(rect.position)
	var half_tile = Vector2(tile_size) / 2.0
	map_info["start_pos"] = tile_origin - half_tile
	map_info["end_pos"] = map_info["start_pos"] + Vector2(map_info["width"], map_info["height"])

func _exit_tree() -> void:
	_current = null
