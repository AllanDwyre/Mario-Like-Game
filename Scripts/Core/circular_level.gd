extends Level
class_name CircularLevel

@export var wrapableLevel : ResetableTilemap
@export var wrap_margin : int = 20
@export var stars_spawns : Array[Marker2D]

var last_star_pos : Vector2 = Vector2.INF
signal star_tooked(player_id : int)
var map_info = {
	"height" : 0,
	"width" : 0,
	"start_pos" : Vector2.ZERO,
	"end_pos" : Vector2.ZERO,
}

func _ready():
	super()
	setup_map_info()
	setup_star()

func setup_star():
	assert(not stars_spawns.is_empty(), "stars_spawns est vide")
	var star_pos = Vector2.INF
	while last_star_pos == star_pos :
		star_pos = stars_spawns.pick_random().global_position
		if stars_spawns.size() < 2 :
			break
	
	var star_scn = load("res://Prefabs/World/starman.tscn") as PackedScene
	var star = star_scn.instantiate() as Starman
	star.star_tooked.connect(on_star_took, CONNECT_ONE_SHOT)
	star.global_position = star_pos
	add_child.call_deferred(star)

func on_star_took(player_id : int):
	setup_star()
	star_tooked.emit(player_id)
	wrapableLevel.reset_tilemap()

func setup_player(): # for multiplayer, we don't wwant to setup player here
	pass

func setup_map_info():
	var rect: Rect2i = wrapableLevel.get_used_rect()
	var tile_size: Vector2i = wrapableLevel.tile_set.tile_size
	
	# Taille en pixels
	map_info["width"]  = rect.size.x * tile_size.x
	map_info["height"] = rect.size.y * tile_size.y
	
	# Position monde (coin haut-gauche)
	var tile_origin = wrapableLevel.map_to_local(rect.position)
	var half_tile = Vector2(tile_size) / 2.0
	map_info["start_pos"] = tile_origin - half_tile
	map_info["end_pos"] = map_info["start_pos"] + Vector2(map_info["width"], map_info["height"])

func wrap_position(pos : Vector2) -> Vector2:
	pos.x = wrapf(pos.x, map_info["start_pos"].x, map_info["end_pos"].x)
	return pos

func _physics_process(_delta):
	#super(_delta)
	for body in get_tree().get_nodes_in_group("Entity"):
		body.global_position = wrap_position(body.global_position)
