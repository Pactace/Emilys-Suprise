extends Node3D

@onready var area = $MeshInstance3D/Area3D
@onready var collision = $MeshInstance3D/StaticBody3D
@onready var green_mat = preload("res://Models/placement_green.tres")
@onready var red_mat = preload("res://Models/placement_red.tres")
@onready var yellow_mat = preload("res://Models/query_yellow.tres")
@onready var mesh = $MeshInstance3D
@onready var offset = $"Placement Marker"
@onready var back_wall_ray = $"Back Wall Ray"
@onready var front_wall_ray = $"Front Wall Ray"

@export_category("Characteristics")
var is_on_wall = false
var camera = null
var previous_cam_z = Vector3(0, 0, 1)

@export_enum("Normal", "Table", "Placeable on Table") var object_type: int

func _process(delta: float) -> void:
	#this is just for some culling effects
	if is_on_wall && camera && camera.basis.z != previous_cam_z:
		var dot_product = -basis.z.dot(camera.basis.z)
		if dot_product > 0.5:
			visible = false
		else: 
			visible = true
		previous_cam_z = camera.basis.z

#We want to check if there are things in the way of our placement
func check_placement() -> bool:
	var overlaps = area.get_overlapping_areas()
	if overlaps.is_empty():
		placement_green()
		return true

	for overlap in overlaps:
		var other = overlap.get_parent().get_parent()
		if object_type == 2 and other.object_type == 1:
			position.y = overlap.get_parent().scale.y
			placement_green()
			return true

	placement_red()
	return false

	
func placed() -> void:
	mesh.material_override = null

func placement_red() -> void:
	mesh.material_override = red_mat
	
func placement_green() -> void:
	mesh.material_override = green_mat

func placement_yellow():
	mesh.material_override = yellow_mat
	
func wall_move():
	if is_on_wall:
		if front_wall_ray.is_colliding():
			print("HIT")
		elif back_wall_ray.is_colliding():
			var collision = back_wall_ray.get_collision_point()
			var normal = back_wall_ray.get_collision_normal()
			var position_offset = -mesh.scale.z/2
			position = collision + normal * position_offset
		
