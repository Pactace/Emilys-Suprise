extends Control

#---Objects---#
@onready var large_object = preload("res://Models/Large Object.tscn")
@onready var medium_object = preload("res://Models/Medium Object.tscn")
@onready var small_object = preload("res://Models/Small Object.tscn")

#---Scene Elements---#
var camera
@export var room : Node3D = null
@onready var tab_container = $TabContainer
@onready var room_size_modifier_display = $"Room Size Modifier"
@onready var vertical_room_size_modifier = $"Room Size Modifier/HBoxContainer/VerticalSliderEdit"
@onready var horizontal_room_size_modifier = $"Room Size Modifier/HBoxContainer2/HorizontalSliderEdit"



#---Placing Variables---#
var instance
var placing = false
var can_place = false
var rotate_object = true

#---Wall Placement Specific Variables---#
var is_wall: bool= false
signal wall_tab(boolean: bool)
var previous_rid = RID()

#---Ray Variables---#
var range = 1000
var collision

#---Selected Object Variables---#
var selected_item = "null"
var edit_object_query
var object_just_placed

#---Edit State Variables---#
enum EditState {Clear, Size_Modify, Object_Select}
var current_state: EditState = EditState.Clear

var Clear = 0
var Size_Modify = 1
var Object_Select = 2

#--- This is to check the change state ---#
func _on_emily_change_game_state(state: int) -> void:
	if state == 1:
		UI_visible()
	else: 
		UI_invisible()
			
func UI_visible():
	visible = true
	get_child(1).can_move = true
	
func UI_invisible():
	visible = false
	get_child(1).can_move = false
	
	#reset everything to the beginning
	tab_container.current_tab = 0
	_update_is_wall_state()
	placing_cancel()

#---TimeLine Functions---#
func _ready() -> void:
	visible = false
	camera = get_viewport().get_camera_3d()
	tab_container.current_tab = 0
		
func _process(delta: float) -> void:
	if visible:
		check_selection()
		if not placing:
			edit_object_position()
		if placing:
			placing_object()
			
func _unhandled_input(event: InputEvent) -> void:
	if visible:
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
				_finalize_edit_object()
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

		if event.is_action_pressed("Pad Left"):
			if current_state == EditState.Object_Select:
				_navigate_tabs(-1)
			elif current_state == EditState.Size_Modify:
				horizontal_room_size_modifier.value -= 1
				room.on_horizontal_change(horizontal_room_size_modifier.value)
		elif event.is_action_pressed("Pad Right"):
			if current_state == EditState.Object_Select:
				_navigate_tabs(1)
			elif current_state == EditState.Size_Modify:
				horizontal_room_size_modifier.value += 1
				room.on_horizontal_change(horizontal_room_size_modifier.value)
		elif event.is_action_pressed("Pad Up") && current_state == EditState.Size_Modify:
			vertical_room_size_modifier.value += 1
			room.on_vertical_change(vertical_room_size_modifier.value)
		elif event.is_action_pressed("Pad Down") && current_state == EditState.Size_Modify:
			vertical_room_size_modifier.value -= 1
			room.on_vertical_change(vertical_room_size_modifier.value)
			
		if event.is_action_pressed("+"):
			if current_state == EditState.Clear or current_state == EditState.Size_Modify:
				tab_container.visible = true
				room_size_modifier_display.visible = false
				current_state = EditState.Object_Select
			elif current_state == EditState.Object_Select:
				tab_container.visible = false
				current_state = EditState.Clear
		if event.is_action_pressed("-"):
			if current_state == EditState.Clear or current_state == EditState.Object_Select:
				tab_container.visible = false
				room_size_modifier_display.visible = true
				current_state = EditState.Size_Modify
			elif current_state == EditState.Size_Modify:
				room_size_modifier_display.visible = false
				current_state = EditState.Clear

#---Selecting Functions---#
#this is for selecting a new object in the UI
func _on_area_2d_area_entered(area: Area2D) -> void:
	if placing == false:
		selected_item = area.get_parent().name

#these are to spawn that object if it is selected
func check_selection():
	if selected_item and Input.is_action_just_pressed("Accept"): 
		instance = _instantiate_selected_object(selected_item)
		if instance:
			placing = true
			get_parent().add_child(instance)

func _instantiate_selected_object(name: String) -> Node3D:
	match name:
		"Large Object", "Large Picture":
			return large_object.instantiate()
		"Medium Object", "Clock":
			return medium_object.instantiate()
		"Small Object", "Small Picture":
			return small_object.instantiate()
		_:
			return null
			
#this is for selecting an object that already exists
func edit_object_position():
	if visible == true:
		var query = create_ray()
		query.collide_with_areas = true
		query.collide_with_bodies = false
		var pick = camera.get_world_3d().direct_space_state.intersect_ray(query)
		if pick:
			edit_object_query = pick.collider.get_parent().get_parent()
			if object_just_placed != edit_object_query and edit_object_query.name != "Room" and edit_object_query.is_on_wall == is_wall:
				edit_object_query.placement_yellow()
				object_just_placed = null
		else:
			_finalize_edit_object()

#---Placing Functions--#
func placing_object():
	var query = create_ray()
	query.collision_mask = (1 if !is_wall else 2)
	
	collision = camera.get_world_3d().direct_space_state.intersect_ray(query)
	if collision:
		instance.visible = true
		
		if is_wall and collision.rid != previous_rid:
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

func _finalize_edit_object():
	if edit_object_query and edit_object_query.name != "Room":
		edit_object_query.placed()
	edit_object_query = null
	object_just_placed = null
	
func placing_cancel():
	placing = false
	selected_item = "null"
	_finalize_edit_object()
	if instance:
		instance.placed()

#---Editing Functions---#
func _rotate_target(target: Node3D, direction: int) -> void:
	if !is_wall:
		target.rotation.y += deg_to_rad(90) * direction
	else:
		var rotation_matrix_z = Basis.from_euler(Vector3(0, 0, deg_to_rad(15) * -direction))
		target.transform.basis = target.transform.basis * rotation_matrix_z

#---Tab Container & Modify Room UI---#
func _navigate_tabs(direction: int) -> void:
	var count = tab_container.get_tab_count()
	tab_container.current_tab = (tab_container.current_tab + direction + count) % count
	_update_is_wall_state()

#---Helper functions---#
#This creates a ray on our screen from the UI to the ground
func create_ray():
	var mouse_pos = get_child(1).position
	var ray_origin = camera.project_ray_origin(mouse_pos)
	var ray_end = ray_origin + camera.project_ray_normal(mouse_pos) * range
	var query = PhysicsRayQueryParameters3D.create(ray_origin, ray_end)
	return query

func _update_is_wall_state() -> void:
	var current_tab = tab_container.get_current_tab_control().name
	var changed = is_wall
	is_wall = (current_tab == "Wall Objects")
	wall_tab.emit(is_wall)
	if changed != is_wall:
		placing_cancel()
