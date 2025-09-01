extends Control

"""
When in the Edit_Objects enum in the UiOverlay state machine this object 
deals with selecting and moving objects already in the scene. It is 
"""

#---Scene Variables---#
var mouse: Marker2D
var camera: Camera3D
var is_wall: bool = false
var wall_name: String = ""

#---Edit Ray---#
var range: int = 1000
var edit_ray : PhysicsRayQueryParameters3D
var previous_rid: RID

#---Object Variables---#
var possible_selected_object: Node3D
var selected_object: Node3D
var object_just_placed: Node3D
var rotate_object: bool = false
var can_place: bool = false

func enabled():
	visible = true

func disabled():
	visible = false
	edit_ray = null

func _process(delta: float) -> void:
	if visible:
		if selected_object:
			placing_object()
		else:
			edit_object_position()
		
func _unhandled_input(event: InputEvent) -> void:
	if visible && possible_selected_object:
		if event.is_action_pressed("Rotate Left") && rotate_object:
			rotate_target(possible_selected_object, -1)
			rotate_object = false
		elif event.is_action_pressed("Rotate Right") && rotate_object:
			rotate_target(possible_selected_object, 1)
			rotate_object = false
		elif event.is_action_released("Rotate Left") or event.is_action_released("Rotate Right"):
			rotate_object = true
		elif event.is_action_pressed("Accept"):
			#if we have selected the new place for the object that has already been confirmed we are going to place it and nullify it
			if selected_object:
				selected_object.placed()
				selected_object = null
				possible_selected_object = null
			#if thats not the case an instead there is a possible_selection we are hovering over we are going to select it
			elif possible_selected_object:
				selected_object = possible_selected_object
				

#---Placing Functions--#
func placing_object():
	var query = create_ray()
	query.collision_mask = (1 if !is_wall else 2)
	
	var collision = camera.get_world_3d().direct_space_state.intersect_ray(query)
	if selected_object:
		if collision:
			selected_object.visible = true
			
			if is_wall and collision.rid != previous_rid:
				var basis = Basis.IDENTITY
				basis.z = collision.normal
				basis.y = Vector3(0,1,0)
				basis.x = basis.y.cross(basis.z) 
				selected_object.basis = basis
				previous_rid = collision.rid
				wall_name = collision.collider.get_parent().name
			
			selected_object.transform.origin = collision.position
			can_place = selected_object.check_placement()
		else:
			selected_object.visible = false

func create_ray():
	var mouse_pos = mouse.position
	var ray_origin = camera.project_ray_origin(mouse_pos)
	var ray_end = ray_origin + camera.project_ray_normal(mouse_pos) * range
	var query = PhysicsRayQueryParameters3D.create(ray_origin, ray_end)
	return query

func edit_object_position():
	edit_ray = create_ray()
	edit_ray.collide_with_areas = true
	edit_ray.collide_with_bodies = false
	var object_area = camera.get_world_3d().direct_space_state.intersect_ray(edit_ray)
	if object_area:
		possible_selected_object = object_area.collider.get_parent().get_parent()
		if object_just_placed != possible_selected_object and possible_selected_object.name != "Room" and possible_selected_object.is_on_wall == is_wall:
			possible_selected_object.placement_yellow()
			object_just_placed = null
	else:
		finalize_edit_object()

func rotate_target(target: Node3D, direction: int) -> void:
	if !is_wall:
		target.rotation.y += deg_to_rad(90) * direction
	else:
		var rotation_matrix_z = Basis.from_euler(Vector3(0, 0, deg_to_rad(15) * -direction))
		target.transform.basis = target.transform.basis * rotation_matrix_z

func finalize_edit_object():
	if possible_selected_object and possible_selected_object.name != "Room":
		possible_selected_object.placed()
	possible_selected_object = null
	object_just_placed = null

#here we are just getting the wall state from the parent
func _on_ui_overlay_is_wall_change(state: bool) -> void:
	is_wall = state
	print(is_wall)
