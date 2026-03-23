@tool
extends Control

const OUTPUT_DIR = "res://assets/previews/"

@onready var registry_picker = $VBox/RegistryRow/RegistryPicker   # EditorResourcePicker
@onready var map_selector    = $VBox/MapSelector                  # OptionButton
@onready var viewport        = $VBox/SubViewportContainer/SubViewport
@onready var camera          = $VBox/SubViewportContainer/SubViewport/Camera2D
@onready var res_x           = $VBox/ResRow/ResX                  # SpinBox
@onready var res_y           = $VBox/ResRow/ResY                  # SpinBox

var current_scene = null
var current_registry: Resource = null   # Registry (YARD)
var loaded_maps: Array = []             # Array[MapData]
var is_dragging = false

# ─── Init ───────────────────────────────────────────────────────────────────

func _ready():
	res_x.value = 320
	res_y.value = 480
	_apply_resolution()

# ─── Registry (YARD) ────────────────────────────────────────────────────────

func _on_registry_changed(res: Resource):
	current_registry = res
	loaded_maps.clear()
	map_selector.clear()

	if current_registry == null:
		return

	# load_all_blocking() retourne un Dictionary[StringName, Resource]
	var entries: Dictionary = current_registry.load_all_blocking()
	for string_id in entries:
		var map_data = entries[string_id]
		if map_data == null:
			continue
		loaded_maps.append(map_data)
		var label = map_data.display_name if map_data.display_name != "" else str(string_id)
		map_selector.add_item(label)

# ─── Map selection ──────────────────────────────────────────────────────────

func _on_map_selected(index: int):
	if current_scene:
		current_scene.queue_free()
		current_scene = null

	if index < 0 or index >= loaded_maps.size():
		return

	var map_data = loaded_maps[index]
	if map_data.scene == null:
		return

	current_scene = map_data.scene.instantiate()
	viewport.add_child(current_scene)
	camera.position = Vector2.ZERO
	camera.zoom = Vector2.ONE

# ─── Resolution ─────────────────────────────────────────────────────────────

func _apply_resolution():
	var size = Vector2i(int(res_x.value), int(res_y.value))
	viewport.size = size
	var container = $VBox/SubViewportContainer
	container.custom_minimum_size = Vector2(size)

# ─── Camera controls ────────────────────────────────────────────────────────

func _on_viewport_gui_input(event: InputEvent):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			is_dragging = event.pressed
	if event is InputEventMouseMotion and is_dragging:
		camera.position -= event.relative / camera.zoom

func _on_reset_camera():
	camera.position = Vector2.ZERO
	camera.zoom = Vector2.ONE

# ─── Capture ────────────────────────────────────────────────────────────────

func _on_capture_pressed():
	var index = map_selector.selected
	if index < 0 or index >= loaded_maps.size():
		push_error("No map selected.")
		return

	var map_data: Resource = loaded_maps[index]

	# Sauvegarde le PNG
	DirAccess.make_dir_recursive_absolute(OUTPUT_DIR)
	var img: Image = viewport.get_texture().get_image()
	var map_name = map_data.display_name.to_lower().replace(" ", "_")
	var png_path = OUTPUT_DIR + map_name + ".png"
	img.save_png(png_path)

	# Force Godot à importer le fichier
	EditorInterface.get_resource_filesystem().scan()
	await EditorInterface.get_resource_filesystem().filesystem_changed

	# Charge la texture fraichement importée et l'assigne à map_data.thumbnail
	var texture: Texture2D = load(png_path)
	map_data.thumbnail = texture

	# Sauvegarde le .tres du MapData modifié
	ResourceSaver.save(map_data)

	print("✅ Thumbnail saved & assigned: ", png_path)
