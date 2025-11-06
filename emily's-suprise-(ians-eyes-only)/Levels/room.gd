@tool
extends Node3D

@export var horizontal_size := 0 : set = set_horizontal_size
@export var vertical_size := 0 : set = set_vertical_size
@export var editable: bool = true
@export var camera: Camera3D

@export_category("Portals")
@export var front_marker: Marker3D
@export var left_marker: Marker3D
@export var right_marker: Marker3D
@export var back_marker: Marker3D

@onready var back_wall: MeshInstance3D = $"Back Wall"
@onready var front_wall: MeshInstance3D = $"Front Wall"
@onready var left_wall: MeshInstance3D = $"Left Wall"
@onready var right_wall: MeshInstance3D = $"Right Wall"
@onready var floor: MeshInstance3D = $"Floor"
@onready var ceiling: MeshInstance3D = $"Ceiling"
@onready var wall_nodes = $"Wall Nodes"
@onready var floor_nodes = $"Floor Nodes"


var forward: bool = false
var horizontal: bool = false

# --- Setters for inspector/runtime ---
func set_horizontal_size(size: int) -> void:
	if horizontal_size != size:
		forward = size < horizontal_size
		horizontal = true
		horizontal_size = size
		update_walls()

func set_vertical_size(size: int) -> void:
	if vertical_size != size:
		forward = size < vertical_size
		horizontal = false
		vertical_size = size
		update_walls()

# --- Wall updates ---
func update_walls() -> void:
	if not is_inside_tree():
		return
	
	# Floor + ceiling
	floor.scale.x = horizontal_size + 8
	floor.scale.z = vertical_size + 8
	ceiling.scale = floor.scale

	# Horizontal scaling
	left_wall.position.x = floor.scale.x
	right_wall.position.x = -floor.scale.x
	front_wall.scale.x = right_wall.position.x - left_wall.position.x
	back_wall.scale.x = right_wall.position.x - left_wall.position.x

	# Vertical scaling
	front_wall.position.z = floor.scale.z
	back_wall.position.z = -floor.scale.z
	left_wall.scale.x = front_wall.position.z - back_wall.position.z
	right_wall.scale.x = front_wall.position.z - back_wall.position.z

	# Update wall nodes
	for wall_node in wall_nodes.get_children():
		if wall_node.has_method("wall_move"):
			wall_node.wall_move(forward, horizontal)

# --- Runtime API (UI buttons etc.) ---
func on_horizontal_change(size: int) -> void:
	set_horizontal_size(size)
	camera.camera_wall_size_effect_vertical = size
	camera._apply_snap()

func on_vertical_change(size: int) -> void:
	set_vertical_size(size)
	camera.camera_wall_size_effect_horizontal = size
	camera._apply_snap()

func change_wallpaper(instance: ShaderMaterial):
	back_wall.material_override = instance.duplicate()
	front_wall.material_override = instance.duplicate()
	right_wall.material_override = instance.duplicate()
	left_wall.material_override = instance.duplicate()
	
	#for some reason I need to jiggle it because its annoying like that lol
	back_wall.jiggle_marker()
	front_wall.jiggle_marker()
	right_wall.jiggle_marker()
	left_wall.jiggle_marker()
	
func change_flooring(instance: StandardMaterial3D):
	floor.material_override = instance
		
func assign_markers():
	front_wall.marker = front_marker
	right_wall.marker = right_marker
	left_wall.marker = left_marker
	back_wall.marker = back_marker

# --- Make sure editor-set values apply at runtime ---
func _ready() -> void:
	change_wallpaper(preload("res://Floor and Wall Textures/BaseWall/BaseWall.tres"))
	change_flooring(preload("res://Floor and Wall Textures/BaseFloor/BaseFloor.tres"))
	update_walls()
	assign_markers()
	camera.camera_wall_size_effect_vertical = horizontal_size
	camera.camera_wall_size_effect_horizontal = vertical_size
