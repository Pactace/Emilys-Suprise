@tool
extends Node3D

@export var horizontal_size := 0 : set = set_horizontal_size
@export var vertical_size := 0 : set = set_vertical_size
@export var editable: bool = true

@onready var back_wall: Node3D = $"Back Wall"
@onready var front_wall: Node3D = $"Front Wall"
@onready var left_wall: Node3D = $"Left Wall"
@onready var right_wall: Node3D = $"Right Wall"
@onready var floor: Node3D = $"Floor"
@onready var ceiling: Node3D = $"Ceiling"
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

func on_vertical_change(size: int) -> void:
	set_vertical_size(size)

func add_object(instance: Node, is_wall: bool) -> void:
	if not is_wall:
		floor_nodes.add_child(instance)
		#we have to wait just a second until the instance can be fully loaded.
		await get_tree().create_timer(0.02).timeout
		print(instance.check_placement())

func add_object_in_empty_space():
	pass

# --- Make sure editor-set values apply at runtime ---
func _ready() -> void:
	update_walls()
