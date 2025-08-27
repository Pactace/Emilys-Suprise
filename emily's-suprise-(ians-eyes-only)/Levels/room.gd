extends Node3D

var horizontal_size := 0
var vertical_size := 0

@onready var back_wall: Node3D = $"Back Wall"
@onready var front_wall: Node3D = $"Front Wall"
@onready var left_wall: Node3D = $"Left Wall"
@onready var right_wall: Node3D = $"Right Wall"
@onready var floor: Node3D = $"Floor"
@onready var ceiling: Node3D = $"Ceiling"
@onready var wall_nodes = $"Wall Nodes"
var forward: bool = false
var horizontal: bool = false

func on_horizontal_change(size: int) -> void:
	if horizontal_size != size:
		if size > horizontal_size: 
			forward = false 
			
		else:
			forward = true
		horizontal = true
		horizontal_size = size
		update_walls()
	
func on_vertical_change(size: int) -> void:
	if vertical_size != size:
		if size > vertical_size: 
			forward = false 
		else:
			forward = true
		horizontal = false
		vertical_size = size
		update_walls()

func update_walls() -> void:
	floor.scale.x = horizontal_size + 8
	floor.scale.z = vertical_size + 8
	ceiling.scale = floor.scale
	
	#scaling horizontally
	left_wall.position.x = floor.scale.x
	right_wall.position.x = -floor.scale.x
	front_wall.scale.x = right_wall.position.x - left_wall.position.x
	back_wall.scale.x = right_wall.position.x - left_wall.position.x

	#scaling vertically
	front_wall.position.z = floor.scale.z
	back_wall.position.z = -floor.scale.z
	left_wall.scale.x = front_wall.position.z - back_wall.position.z
	right_wall.scale.x = front_wall.position.z - back_wall.position.z
	
	#finally we update all of the nodes on the wall
	for wall_node in wall_nodes.get_children():
		if wall_node.has_method("wall_move"):
			wall_node.wall_move(forward, horizontal)
	
