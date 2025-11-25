extends CharacterBody3D

#---Player Variables---#
@onready var emily_model = $EmilyAnimations
@onready var emily_overlay = $EmilyOverlay
@onready var audioplayer = $AudioStreamPlayer3D
signal play_walking()
signal play_idle()
var idle_or_walking = true
@export var SPEED = 3.25
var old_position
var new_center_bool = false
var triplethreat_step_done = false  # 👈 new flag

#---Scene Variables---#
@onready var camera: Camera3D = $"../Camera"
@onready var ui_overlay: Control = $"../UiOverlay"


enum PlayerState {Moving, Editing}
var current_state: PlayerState = PlayerState.Moving


func _ready() -> void:
	# --- Door spawn logic ---
	var doors_node = get_node_or_null("../Doors")
	if doors_node:
		var door_path = "../Doors/" + GameSingleton.door_name
		var door = get_node_or_null(door_path)
		
		if door:
			#print("Found door:", door.name)
			global_position = door.marker.global_position
			global_rotation.y = door.global_rotation.y - deg_to_rad(90)
		else:
			print("No door found at path:", door_path)
	else:
		print("No 'Doors' node found at ../Doors")

	# --- If this is a triple threat room, do a little startup step ---
	if camera.triplethreat:
		triplethreat_step_done = false  # reset the flag


func _physics_process(delta: float) -> void:
	if current_state == PlayerState.Moving:
		if camera.triplethreat and !triplethreat_step_done:
			# 👣 Simulate one frame of forward movement using walk_around_logic
			var fake_input_dir = Vector2(0, 1) # equivalent to pressing "Up"
			walk_around_logic(delta, fake_input_dir)
			if GameSingleton.door_name != "StairsideLibraryEntrance":
				fake_input_dir = Vector2(0, -1) # equivalent to pressing "Up"
			walk_around_logic(delta, fake_input_dir)
			triplethreat_step_done = true
		else:
			walk_around_logic(delta)


func switch_states():
	if current_state == PlayerState.Moving:
		current_state = PlayerState.Editing
		ui_overlay.enabled()
		visible = false
		old_position = position
		position.y = -10
		emily_model.visible = false
		audioplayer.stop()
	else:
		current_state = PlayerState.Moving
		ui_overlay.disabled()
		visible = true
		position = old_position
		emily_model.visible = true
		


func walk_around_logic(delta: float, forced_input_dir := Vector2.ZERO):
	var input_dir := forced_input_dir if forced_input_dir != Vector2.ZERO else Input.get_vector("Left", "Right", "Up", "Down")

	# --- Camera-relative movement ---
	if input_dir != Vector2.ZERO:
		if idle_or_walking:
			audioplayer.play(.15)
			play_walking.emit()
			idle_or_walking = false

		var cam_forward = camera.global_transform.basis.z
		var cam_right = camera.global_transform.basis.x

		cam_forward.y = 0
		cam_right.y = 0
		cam_forward = cam_forward.normalized()
		cam_right = cam_right.normalized()

		var move_dir = (cam_right * input_dir.x + cam_forward * input_dir.y).normalized()
		
		rotation.y = atan2(move_dir.x, move_dir.z)
		velocity.x = move_dir.x * SPEED
		velocity.z = move_dir.z * SPEED
		
		if camera.triplethreat:
			if global_position.x > 7 and !new_center_bool:
				camera.set_center(Vector3(10,0,0))
				new_center_bool = true
			elif global_position.x < -7 and !new_center_bool:
				camera.set_center(Vector3(-10,0,0))
				new_center_bool = true
			elif global_position.x < 7 and global_position.x > -7 and new_center_bool:
				camera.set_center(Vector3(1,0,0))
				new_center_bool = false
	else:
		if !idle_or_walking:
			audioplayer.stop()
			play_idle.emit()
			idle_or_walking = true
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()
	
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("Edit Mode"):
		switch_states()
