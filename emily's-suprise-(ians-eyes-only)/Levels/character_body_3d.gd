extends CharacterBody3D

#---Player Variables---#
@onready var emily_model = $EmilyAnimations
signal play_walking()
signal play_idle()
var idle_or_walking = true
@export var SPEED = 3.25
var old_position

#---Scene Variables---#
@onready var camera: Camera3D = $"../Camera"
@onready var ui_overlay: Control = $"../UiOverlay"

enum PlayerState {Moving, Editing}
var current_state: PlayerState = PlayerState.Moving

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("Edit Mode"):
		switch_states()

func _physics_process(delta: float) -> void:
	if current_state == PlayerState.Moving:
		walk_around_logic(delta)

func switch_states():
	if current_state == PlayerState.Moving:
		current_state = PlayerState.Editing
		ui_overlay.enabled()
		visible = false
		old_position = position
		position = Vector3(0,-10, 0)
	else:
		current_state = PlayerState.Moving
		ui_overlay.disabled()
		visible = true
		position = old_position
	
func walk_around_logic(delta: float):
	var input_dir := Input.get_vector("Left", "Right", "Up", "Down")

	# --- Camera-relative movement ---
	if input_dir != Vector2.ZERO:
		if idle_or_walking:
			play_walking.emit()
			idle_or_walking = false
		#First we need to get the camera axese.
		var cam_forward = camera.global_transform.basis.z
		var cam_right = camera.global_transform.basis.x

		#Here we are going to ignore vertical tilt
		cam_forward.y = 0
		cam_right.y = 0
		cam_forward = cam_forward.normalized()
		cam_right = cam_right.normalized()

		#Movement direction will now be directly coorelated to camera direction
		var move_dir = (cam_right * input_dir.x + cam_forward * input_dir.y).normalized()
		
		rotation.y = atan2(move_dir.x, move_dir.z)
		velocity.x = move_dir.x * SPEED
		velocity.z = move_dir.z * SPEED
	else:
		if !idle_or_walking:
			play_idle.emit()
			idle_or_walking = true
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
		

	move_and_slide()
