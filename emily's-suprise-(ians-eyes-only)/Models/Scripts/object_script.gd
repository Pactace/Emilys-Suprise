class_name Furniture
extends Node3D
@export var area_path: NodePath
@onready var area: Area3D = get_node(area_path)
@onready var green_mat = preload("res://Models/placement_green.tres")
@onready var red_mat = preload("res://Models/placement_red.tres")
@onready var yellow_mat = preload("res://Models/query_yellow.tres")
@onready var mesh = $MeshInstance3D
@onready var wall_ray = $"Wall Ray"
@export_category("Characteristics")
var is_on_wall = false
var is_horizontal = false
var camera = null
var previous_cam_z = Vector3(0, 0, 1)
var overlapping = false
var collision

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
	for child in get_children():
		if child is MeshInstance3D:
			child.material_override = null

func placement_red() -> void:
	for child in get_children():
		if child is MeshInstance3D:
			child.material_override = red_mat
	
func placement_green() -> void:
	for child in get_children():
		if child is MeshInstance3D:
			child.material_override = green_mat

func placement_yellow():
	for child in get_children():
		if child is MeshInstance3D:
			child.material_override = yellow_mat
	
func clear_material() -> void:
	for child in get_children():
		if child is MeshInstance3D:
			child.material_override = null
	
func wall_move(forward: bool, horizontal: bool):
	if is_on_wall and wall_ray.is_colliding() and is_horizontal == horizontal:
		var collision_point: Vector3 = wall_ray.get_collision_point()
		var normal: Vector3 = wall_ray.get_collision_normal()
		
		if forward == false:
			position = collision_point
		else:
			var position_offset = -area.scale.z * 2
			position = collision_point + normal * position_offset
