extends Area3D

var door
@onready var label = $Label
@onready var camera: Camera3D = get_viewport().get_camera_3d()

func _ready() -> void:
	label.visible = false  # hide by default

func _process(delta: float) -> void:
	if not camera or not is_instance_valid(camera):
		camera = get_viewport().get_camera_3d()
		return
	
	# Project 3D position into 2D screen space
	var screen_pos = camera.unproject_position(global_position)
	label.position = screen_pos
	
	# Hide if behind camera or no active door
	var in_front = not camera.is_position_behind(global_position)
	label.visible = in_front and door != null


func _on_body_entered(body: Node3D) -> void:
	var parent = body.get_parent()
	
	if parent and parent.get_script() != null:
		var script_path = parent.get_script().resource_path
		
		match script_path.get_file():
			"door.gd", "open_entrance.gd":
				door = parent
				
				# Check if door is unlocked yet
				if door.unlocked_day <= GameSingleton.current_time.day:
					label.text = "Press A to enter"
				else:
					label.text = "I can't go there yet"
				
				label.visible = true
				print("Entered:", parent.name)
	else:
		label.visible = false


func _on_body_exited(body: Node3D) -> void:
	label.visible = false
	door = null


func _unhandled_input(event: InputEvent) -> void:
	if door and event.is_action_pressed("Accept"):
		if door.unlocked_day <= GameSingleton.current_time.day:
			door.enter_portal()
		else:
			print("Door is locked — cannot enter yet.")
