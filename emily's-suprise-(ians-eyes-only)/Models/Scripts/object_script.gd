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
var placable_location_found

@export_enum("Normal", "Table", "Placeable on Table") var object_type: int

@export var skins = {}

func _ready() -> void:
	camera = get_viewport().get_camera_3d()

func _process(delta: float) -> void:
	#this is just for some culling effects
	if is_on_wall && camera && camera.basis.z != previous_cam_z:
		var dot_product = -basis.z.dot(camera.basis.z)
		if dot_product > 15:
			visible = false
		else: 
			visible = true
		previous_cam_z = camera.basis.z

#We want to check if there are things in the way of our placement
func check_placement() -> bool:
	if object_type == 2:
		var ray_start = global_transform.origin + Vector3(0, 10, 0) # Start above the object
		var ray_end = global_transform.origin + Vector3(0, -10, 0) # End below the object
		
		var space_state = get_world_3d().direct_space_state
		var query = PhysicsRayQueryParameters3D.new()
		query.from = ray_start
		query.to = ray_end
		query.collide_with_bodies = false
		query.collide_with_areas = true
		query.exclude = [area.get_rid()] # Exclude the object itself if needed
		var result = space_state.intersect_ray(query)
		if result and result.collider.get_parent().get_parent().object_type == 1:
			position.y = result.position.y
			placement_green()
			return true
			
	var overlaps = area.get_overlapping_areas()
	if overlaps.is_empty():
		placement_green()
		return true


	placement_red()
	return false
	
func placed() -> void:
	_apply_to_meshes(self, func(mesh):
		if !is_on_wall:
			mesh.set_layer_mask_value(16, true)
		mesh.material_overlay = null
	)

func placement_red() -> void:
	_apply_to_meshes(self, func(mesh):
		mesh.material_overlay = red_mat
	)

func placement_green() -> void:
	_apply_to_meshes(self, func(mesh):
		mesh.material_overlay = green_mat
	)

func placement_yellow() -> void:
	_apply_to_meshes(self, func(mesh):
		mesh.material_overlay = yellow_mat
	)

func clear_material() -> void:
	_apply_to_meshes(self, func(mesh):
		mesh.material_overlay = null
	)

# --- Helper function for recursion ---
func _apply_to_meshes(node: Node, action: Callable) -> void:
	for child in node.get_children():
		if child is MeshInstance3D:
			action.call(child)
		else:
			_apply_to_meshes(child, action)
	
func wall_move(forward: bool, horizontal: bool):
	if is_on_wall and wall_ray.is_colliding() and is_horizontal == horizontal:
		var collision_point: Vector3 = wall_ray.get_collision_point()
		var normal: Vector3 = wall_ray.get_collision_normal()
		
		if forward == false:
			position = collision_point
		else:
			var position_offset = -area.scale.z * 2
			position = collision_point + normal * position_offset
