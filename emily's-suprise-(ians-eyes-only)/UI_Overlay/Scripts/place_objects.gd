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
var spawned_object: PackedScene = null
var spawned_object_is_wall: bool = false
var possible_selected_object: Node3D
var selected_object: Node3D
var object_just_placed: Node3D
var rotate_object: bool = false
var can_place: bool = false
var in_cache: bool = false

@onready var triggers_to_rotate = $Triggers_To_Rotate
@onready var move_place = $Move_Place
@onready var to_place_move_label = $Move_Place/Label
@onready var change_colors = $Change_Colors
@onready var leave_wall = $"Delete_Leave Wall"
@onready var leave_wall_label = $"Delete_Leave Wall/Label"
@onready var pallet_swap = $PalletSwap

func enabled():
	visible = true
	pallet_swap.visible = false
	if spawned_object:
		_handle_spawned_object()
	
func disabled():
	visible = false
	edit_ray = null
	is_wall = false
	if possible_selected_object or selected_object:
		possible_selected_object.placed()
		possible_selected_object = null
		selected_object = null
		triggers_to_rotate.visible = false
		move_place.visible = false
		change_colors.visible = false
		leave_wall.visible = false
		pallet_swap.visible = false
		to_place_move_label.text = "To Select"
		

func _process(delta: float) -> void:
	if visible:
		if selected_object:
			placing_object()
			leave_wall.visible = true
			leave_wall_label.text = "Delete Object"
		else:
			edit_object_position()
		if is_wall && not selected_object:
			leave_wall.visible = true
			leave_wall_label.text = "Leave Wall"
		
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
			if selected_object and can_place:
				selected_object.placed()
				selected_object = null
				possible_selected_object = null
				triggers_to_rotate.visible = false
				move_place.visible = false
				change_colors.visible = false
				leave_wall.visible = false
				to_place_move_label.text = "To Select"
			#if thats not the case an instead there is a possible_selection we are hovering over we are going to select it
			elif possible_selected_object && possible_selected_object.is_on_wall == is_wall:
				selected_object = possible_selected_object
			elif possible_selected_object and !is_wall and possible_selected_object.is_on_wall:
				is_wall = true
				camera.wall_update(is_wall)
		elif event.is_action_pressed("Toggle Colors & Spacing"):
			if pallet_swap.visible == false:
				pallet_swap.instance = possible_selected_object
				pallet_swap.enabled()
			else:
				pallet_swap.disabled()
					
	if event.is_action_pressed("Cancel"):
		if selected_object:
				selected_object.free()
				selected_object = null
				possible_selected_object = null
				triggers_to_rotate.visible = false
				move_place.visible = false
				change_colors.visible = false
				leave_wall.visible = false
				to_place_move_label.text = "To Select"
		elif is_wall == true:
			is_wall = false
			camera.wall_update(is_wall)
				

#---Placing Functions--#
func placing_object():
	var query = create_ray()
	query.collision_mask = (1 if !selected_object.is_on_wall else 2)
	to_place_move_label.text = "To Place"
	
	var collision = camera.get_world_3d().direct_space_state.intersect_ray(query)
	if selected_object:
		if collision:
			selected_object.visible = true
			
			if selected_object.is_on_wall: #and collision.rid != previous_rid:
				var basis = Basis.IDENTITY
				basis.z = collision.normal
				basis.y = Vector3(0,1,0)
				basis.x = basis.y.cross(basis.z) 
				selected_object.basis = basis
				previous_rid = collision.rid
				wall_name = collision.collider.get_parent().name
				selected_object.scale = Vector3(0.3, 0.3, 0.3) 
			
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
	
	#here we are checking if there is an object area and if that object area is an actual placable object
	if object_area and object_area.collider.get_parent().get_parent().get_script() != null:
		#here we check if the an old possible_selected_object is getting replaced with a new one
		var old_possible_selected_object
		if possible_selected_object:
			old_possible_selected_object = possible_selected_object
		
		#next we assign the new_possible_selected object and make the edit ui prompts show up
		possible_selected_object = object_area.collider.get_parent().get_parent()
		if object_just_placed != possible_selected_object:
			if old_possible_selected_object:
				old_possible_selected_object.placed()
			possible_selected_object.placement_yellow()
			object_just_placed = null
			triggers_to_rotate.visible = true if is_wall == false else false
			leave_wall.visible = true if is_wall == true else false
			move_place.visible = true
			change_colors.visible = true
			to_place_move_label.text = "To Select"
	else:
		finalize_edit_object()

func rotate_target(target: Node3D, direction: int) -> void:
	if !target.is_on_wall:
		target.rotation.y += deg_to_rad(90) * direction
	#else:
		#var rotation_matrix_z = Basis.from_euler(Vector3(0, 0, deg_to_rad(15) * -direction))
		#target.transform.basis = target.transform.basis * rotation_matrix_z

func finalize_edit_object():
	if possible_selected_object:
		possible_selected_object.placed()
	possible_selected_object = null
	object_just_placed = null
	triggers_to_rotate.visible = false
	move_place.visible = false
	change_colors.visible = false
	leave_wall.visible = false
	to_place_move_label.text = "To Select"

#here we are just getting the wall state from the parent
func _on_ui_overlay_is_wall_change(state: bool) -> void:
	is_wall = state
	
func assign_selected_object(object: PackedScene, is_wall: bool, in_resource_cache: bool):
	spawned_object = object
	spawned_object_is_wall = is_wall
	in_cache = in_resource_cache
	
	
func _handle_spawned_object():
		var instance = spawned_object.instantiate()
		get_parent().get_parent().add_child(instance)
		instance.is_on_wall = spawned_object_is_wall
		instance.area = instance.get_node(instance.area_path)
		possible_selected_object = instance
		selected_object = possible_selected_object
		spawned_object = null
		spawned_object_is_wall = false
		print(selected_object.name)
		if instance.is_on_wall:
			selected_object.scale = Vector3(0.3, 0.3, 0.3) 
		else:
			selected_object.scale = Vector3(0.3, 0.3, 0.3) 
		mouse.position = Vector2(325, 250)
	
