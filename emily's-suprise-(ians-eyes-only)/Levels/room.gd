extends Node3D

var horizontal_size := 0.0
var vertical_size := 0.0

@onready var back_wall: Node3D = $"Back Wall"
@onready var front_wall: Node3D = $"Front Wall"
@onready var left_wall: Node3D = $"Left Wall"
@onready var right_wall: Node3D = $"Right Wall"
@onready var floor: Node3D = $"Floor"
@onready var ceiling: Node3D = $"Ceiling"

func on_horizontal_change(size: float) -> void:
	horizontal_size = size
	update_walls()
	
func on_vertical_change(size: float) -> void:
	vertical_size = size
	update_walls()

func update_walls() -> void:
	# Assuming floor is a PlaneMesh scaled in X/Z
	floor.scale.x = horizontal_size + 8
	floor.scale.z = vertical_size + 8
	ceiling.scale = floor.scale
	
	#scaling horizontally
	left_wall.position.x = floor.scale.x
	right_wall.position.x = -floor.scale.x
	front_wall.scale.x = right_wall.position.x - left_wall.position.x
	back_wall.scale.x = right_wall.position.x - left_wall.position.x

	front_wall.position.z = floor.scale.z
	back_wall.position.z = -floor.scale.z
	left_wall.scale.x = front_wall.position.z - back_wall.position.z
	right_wall.scale.x = front_wall.position.z - back_wall.position.z
	
