extends TileMapLayer
class_name ResetableTilemap

var initial_tiles = []
func _ready() -> void:
	for cell in get_used_cells():
		initial_tiles.append({
			"pos": cell,
			"tile": get_cell_source_id(cell),
			"atlas_coords": get_cell_atlas_coords(cell),
			"alternative": get_cell_alternative_tile(cell)
		})

func reset_tilemap():
	clear()
	for data in initial_tiles:
		set_cell(data["pos"], data["tile"], data["atlas_coords"], data["alternative"])
	#notify_runtime_tile_data_update()
