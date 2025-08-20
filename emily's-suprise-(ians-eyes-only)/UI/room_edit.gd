extends Control

@onready var large_object = preload("res://Models/Large Object.tscn")
@onready var medium_object = preload("res://Models/Medium Object.tscn")
@onready var small_object = preload("res://Models/Small Object.tscn")

var camera
var instance
var placing = false
var range = 1000

var selected_item = "null"

func _ready() -> void:
	visible = false
	camera = get_viewport().get_camera_3d()

func _on_emily_change_game_state(state: int) -> void:
	if state > 0:
		visible = true
		get_child(1).can_move = true
	else: 
		visible = false
		get_child(1).can_move = false

func _process(delta: float) -> void:
	check_selection()
	if placing:
		var mouse_pos = get_child(1).position
		var ray_origin = camera.project_ray_origin(mouse_pos)
		var ray_end = ray_origin + camera.project_ray_normal(mouse_pos) * range
		var query = PhysicsRayQueryParameters3D.create(ray_origin, ray_end)
		query.collision_mask = 1 #we just worried about the floor
		var collision = camera.get_world_3d().direct_space_state.intersect_ray(query)
		if collision:
			instance.transform.origin = collision.position
		
func _on_area_2d_area_entered(area: Area2D) -> void:
	selected_item = area.get_parent().name

func check_selection():
	if selected_item:
		if Input.is_action_just_pressed("Accept"): 
			match selected_item:
				"Large Object":
					instance = large_object.instantiate()
				"Medium Object":
					instance = medium_object.instantiate()
				"Small Object":
					instance = small_object.instantiate()
			placing = true
			get_parent().add_child(instance)
	
