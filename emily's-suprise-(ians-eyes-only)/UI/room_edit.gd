extends Control

@onready var large_object = preload("res://Models/Large Object.tscn")
@onready var medium_object = preload("res://Models/Medium Object.tscn")
@onready var small_object = preload("res://Models/Small Object.tscn")

var camera
var instance
var placing = false
var range = 1000
var can_place = false
var collision
var edit_object_query
var object_just_placed
var rotate_object = true
var selected_item = "null"
@onready var tab_container = $TabContainer
var is_wall: bool= false
signal wall_tab(boolean: bool)
var previous_rid = RID()

#this is if the editing UI is enabled
func _on_emily_change_game_state(state: int) -> void:
	if state > 0:
		visible = true
		get_child(1).can_move = true
	else: 
		visible = false
		get_child(1).can_move = false
		tab_container.current_tab = 0
		_update_is_wall_state()
		placing = false
		selected_item = "null"
		if instance and placing and instance != edit_object_query:
			instance.queue_free()

func _ready() -> void:
	visible = false
	camera = get_viewport().get_camera_3d()
	tab_container.current_tab = 0
		
func _process(delta: float) -> void:
	check_selection()
	if not placing:
		edit_object_position()
	if placing:
		placing_object()
			
#This creates a ray on our screen from the UI to the ground
func create_ray():
	var mouse_pos = get_child(1).position
	var ray_origin = camera.project_ray_origin(mouse_pos)
	var ray_end = ray_origin + camera.project_ray_normal(mouse_pos) * range
	var query = PhysicsRayQueryParameters3D.create(ray_origin, ray_end)
	return query

#this is for selecting a new object in the UI
func _on_area_2d_area_entered(area: Area2D) -> void:
	if placing == false:
		selected_item = area.get_parent().name

#this is to spawn that object if it is selected
func check_selection():
	if selected_item:
		if Input.is_action_just_pressed("Accept"): 
			if placing:
				instance.queue_free()
			match selected_item:
				"Large Object":
					instance = large_object.instantiate()
				"Medium Object":
					instance = medium_object.instantiate()
				"Small Object":
					instance = small_object.instantiate()
				"Large Picture":
					instance = large_object.instantiate()
				"Clock":
					instance = medium_object.instantiate()
				"Small Picture":
					instance = small_object.instantiate()
			placing = true
			get_parent().add_child(instance)

#this is for when I have placed an object and want to go back and select it to edit it.	
func edit_object_position():
	var query = create_ray()
	query.collide_with_areas = true
	query.collide_with_bodies = false
	var pick = camera.get_world_3d().direct_space_state.intersect_ray(query)
	if pick:
		edit_object_query = pick.collider.get_parent().get_parent()
		if object_just_placed != edit_object_query:
			edit_object_query.placement_yellow()
			object_just_placed = null
	else:
		if edit_object_query:
			edit_object_query.placed()
			edit_object_query = null
			object_just_placed = null

#this is after selection (by new creation or editing) to place the object
func placing_object():
	var query = create_ray()
	query.collision_mask = (1 if !is_wall else 2)
	
	collision = camera.get_world_3d().direct_space_state.intersect_ray(query)
	if collision:
		instance.visible = true
		
		if is_wall && collision.rid != previous_rid:
			var basis = Basis.IDENTITY
			basis.z = collision.normal
			basis.y = Vector3(0,1,0)
			basis.x = basis.y.cross(basis.z) 
			instance.basis = basis
			previous_rid = collision.rid
			
		var marker = instance.get_node("Placement Marker")
		instance.transform.origin = collision.position + marker.transform.origin
		
		can_place = instance.check_placement()
	else:
		instance.visible = false
		
func _update_is_wall_state() -> void:
	var current_tab = tab_container.get_current_tab_control().name
	is_wall = (current_tab == "Wall Objects")
	wall_tab.emit(is_wall)

func _rotate_target(target: Node3D, direction: int) -> void:
	if !is_wall:
		target.rotation.y += deg_to_rad(90) * direction
	else:
		var rotation_matrix_z = Basis.from_euler(Vector3(0, 0, deg_to_rad(15) * -direction))
		target.transform.basis = target.transform.basis * rotation_matrix_z

func _unhandled_input(event: InputEvent) -> void:
	# placing / selecting
	if event.is_action_pressed("Accept"):
		if placing and can_place and collision:
			placing = false
			can_place = false
			instance.placed()
			instance.camera = camera
			if is_wall:
				instance.is_on_wall = true
			selected_item = null
			if instance.has_node("CollisionShape3D"):
				instance.get_node("CollisionShape3D").disabled = false
			object_just_placed = instance
			edit_object_query = null
		elif edit_object_query:
			placing = true
			instance = edit_object_query
			if instance.has_node("CollisionShape3D"):
				instance.get_node("CollisionShape3D").disabled = true

	# rotation
	var target: Node3D = null
	if placing and instance:
		target = instance
	elif edit_object_query and edit_object_query != object_just_placed:
		target = edit_object_query

	if target:
		if rotate_object:
			if event.is_action_pressed("Rotate Left"):
				_rotate_target(target, -1)
				rotate_object = false
			elif event.is_action_pressed("Rotate Right"):
				_rotate_target(target, 1)
				rotate_object = false
		elif event.is_action_released("Rotate Left") or event.is_action_released("Rotate Right"):
			rotate_object = true

	# tab navigation
	if event.is_action_pressed("Tab Left"):
		var count = tab_container.get_tab_count()
		tab_container.current_tab = (tab_container.current_tab - 1 + count) % count
		_update_is_wall_state()

	elif event.is_action_pressed("Tab Right"):
		var count = tab_container.get_tab_count()
		tab_container.current_tab = (tab_container.current_tab + 1) % count
		_update_is_wall_state()
