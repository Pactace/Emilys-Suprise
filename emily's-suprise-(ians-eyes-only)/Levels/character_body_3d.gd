extends CharacterBody3D

@export var SPEED = 5.0
const JUMP_VELOCITY = 4.5

@onready var cam: Camera3D = $"../Camera"

var game_state = 0
var old_position
signal change_game_state(state: int)

var game_states = [
	{"name": "Walk Around" },
	{"name": "Room Edit"},
	{"name": "Wall Edit"}
]

func _physics_process(delta: float) -> void:
	switch_states(delta)
	if game_state == 0:
		walk_around_logic(delta)
		

func switch_states(delta: float):
	if Input.is_action_just_pressed("Edit Mode"):
		if game_state == 0:
			game_state = 1
			emit_signal("change_game_state", game_state)
			visible = false
			old_position = position
			position = Vector3(0,-10, 0)
		else:
			game_state = 0
			emit_signal("change_game_state", game_state)
			visible = true
			position = old_position
	
func walk_around_logic(delta: float):
	if not is_on_floor():
		velocity += get_gravity() * delta

	var input_dir := Input.get_vector("Left", "Right", "Up", "Down")

	# --- Camera-relative movement ---
	if input_dir != Vector2.ZERO:
		#First we need to get the camera axese.
		var cam_forward = cam.global_transform.basis.z
		var cam_right = cam.global_transform.basis.x

		#Here we are going to ignore vertical tilt
		cam_forward.y = 0
		cam_right.y = 0
		cam_forward = cam_forward.normalized()
		cam_right = cam_right.normalized()

		#Movement direction will now be directly coorelated to camera direction
		var move_dir = (cam_right * input_dir.x + cam_forward * input_dir.y).normalized()

		velocity.x = move_dir.x * SPEED
		velocity.z = move_dir.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()
