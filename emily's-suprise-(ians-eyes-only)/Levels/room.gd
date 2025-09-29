@tool
extends Node3D

@export var horizontal_size := 0 : set = set_horizontal_size
@export var vertical_size := 0 : set = set_vertical_size
@export var editable: bool = true
@export var camera: Camera3D

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

func on_vertical_change(size: int) -> void:
	set_vertical_size(size)

func add_object(instance: Node, is_wall: bool) -> void:
	if not is_wall:
		add_object_on_ground(instance)
	else:
		add_object_on_wall(instance)

func add_object_on_ground(instance: Node3D):
	instance.visible = false
	floor_nodes.add_child(instance)
	#we have to wait just a second until the instance can be fully loaded.
	await get_tree().create_timer(0.02).timeout
	
	#these are the directions its going to cicle around the main guy
	var directions = [
		Vector3(0, 0, 1),   # South
		Vector3(1, 0, 1),  # SouthEast
		Vector3(1, 0, 0),   # East
		Vector3(1, 0, -1),  # NorthEast
		Vector3(0, 0, -1),  # North
		Vector3(-1, 0, -1), # NorthWest
		Vector3(-1, 0, 0),  # West
		Vector3(-1, 0, 1)   # SouthWest
	]
	#if it collides with something we are going go around the collision
	var colliding_area = instance.area.get_overlapping_areas().front()
	if colliding_area:
		var colliding_object = colliding_area.get_parent()
		for direction in directions:
			#We are going to reset it to the colliding objects position so the reallocation math is easier
			instance.position.x = colliding_object.position.x
			instance.position.z = colliding_object.position.z
			#Relocation math
			instance.position += (colliding_object.scale * direction + instance.scale * direction)
			#got to wait a second before checking placement
			await get_tree().create_timer(0.02).timeout
			if instance.check_placement():
				break
	#temporary fix,
	if instance.check_placement() == false:
		print("Too many objects")
		instance.queue_free()
	#finally we place the object.
	instance.placed()
	instance.visible = true

func change_wallpaper(instance: StandardMaterial3D):
	back_wall.material_override = instance
	front_wall.material_override = instance
	right_wall.material_override = instance
	left_wall.material_override = instance
	
func change_flooring(instance: StandardMaterial3D):
	floor.material_override = instance

#this is a very mathy function tbh
func add_object_on_wall(instance: Node3D):
	var from: Vector3 = camera.global_position
	var to: Vector3 = from + -camera.global_transform.basis.z * 100.0

	var space_state = get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.create(from, to)
	query.collision_mask = 2
	var result = space_state.intersect_ray(query)
	if result:
		wall_nodes.add_child(instance)
		instance.is_on_wall = true
		if round(abs(result.normal.x)) == 1:
			instance.is_horizontal = true
			
		var basis = Basis.IDENTITY
		basis.z = result.normal
		basis.y = Vector3(0,1,0)
		basis.x = basis.y.cross(basis.z) 
		instance.basis = basis
		
		var wall = result.collider.get_parent()
		instance.transform.origin = Vector3(result.position.x, wall.position.y, result.position.z)
		await get_tree().create_timer(0.02).timeout

		#these are the directions its going to be left and right around the main guy
		var directions = [
			Vector3(1, 0, 1),   # East
			Vector3(-1, 0, -1),  # West
		]
		
		#depending which wall the object is on we are going to modify these direction vectors
		var horizontal_vector = Vector3(0,1,1)
		var vertical_vector = Vector3(1,1,0)
		
		#if it collides with something we are going go around the collision
		var colliding_area = instance.area.get_overlapping_areas().front()
		print(colliding_area)
		if colliding_area:
			var colliding_object = colliding_area.get_parent()
			for direction in directions:
				#We are going to reset it to the colliding objects position so the reallocation math is easier
				if instance.is_horizontal == true:
					instance.position.z = colliding_object.position.z
				else:
					instance.position.x = colliding_object.position.x
				
				#this is to decide which direction its going to go depending on the wall
				var direction_vector_turnary = (vertical_vector if !instance.is_horizontal else horizontal_vector * 1.4)
				#Relocation math
				instance.position += (colliding_object.scale * direction * direction_vector_turnary
				 + instance.scale * direction * direction_vector_turnary)
				#got to wait a second before checking placement
				await get_tree().create_timer(0.02).timeout
				if instance.check_placement():
					print("we chillin")
					break
		#temporary fix,
		if instance.check_placement() == false:
			print("Too many objects")
			instance.queue_free()
		#finally we place the object.
		instance.placed()
		instance.scale = Vector3(28,28,28)
		instance.visible = true

# --- Make sure editor-set values apply at runtime ---
func _ready() -> void:
	update_walls()
