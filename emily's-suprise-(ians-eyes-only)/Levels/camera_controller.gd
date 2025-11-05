extends Camera3D

@export var triplethreat = false
var center = Vector3(0,0,0)
var new_center_bool = false
# --- Camera Snap Constants ---
const CAMERA_HEIGHT := 10.0
const CAMERA_DISTANCE := 15.0
const CAMERA_TILT_ANGLE := deg_to_rad(-27.5)
const CAMERA_SNAP_COUNT := 4

# --- Wall View Constants ---
const WALL_VIEW_HEIGHT := 5.0
const WALL_VIEW_POS := Vector3(0, WALL_VIEW_HEIGHT, 0)
const WALL_VIEW_TILT := 0.0

# --- Rotation Angles ---
const ROT_FRONT := deg_to_rad(0)
const ROT_LEFT := deg_to_rad(-90)
const ROT_BACK := deg_to_rad(180)
const ROT_RIGHT := deg_to_rad(90)

# --- Lerp ---
var LERP_SPEED := 5.0  # bigger = faster

# --- Snap State ---
var snap_index := 0
var snap_positions = [
	{ "pos": Vector3(0 + center.x, CAMERA_HEIGHT, CAMERA_DISTANCE),   "rot": ROT_FRONT, "name": "front" },
	{ "pos": Vector3(-CAMERA_DISTANCE + center.x, CAMERA_HEIGHT, 0), "rot": ROT_LEFT,  "name": "left" },
	{ "pos": Vector3(0, CAMERA_HEIGHT + center.x, -CAMERA_DISTANCE), "rot": ROT_BACK,  "name": "back"},
	{ "pos": Vector3(CAMERA_DISTANCE+ center.x, CAMERA_HEIGHT, 0),  "rot": ROT_RIGHT, "name": "right" }
]

# --- State ---
var wall_view: bool = false
var target_pos: Vector3
var target_rot_y: float
var target_rot_x: float = CAMERA_TILT_ANGLE
var target_fov: float = 75.0
var camera_wall_size_effect_horizontal = 0
var camera_wall_size_effect_vertical = 0

func _ready():
	target_pos = position
	target_rot_y = rotation.y
	target_rot_x = rotation.x
	target_fov = fov
	_apply_snap()

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("Camera Snap Left"):
		snap_left()
	elif Input.is_action_just_pressed("Camera Snap Right"):
		snap_right()

	# Smooth transitions
	position = position.lerp(target_pos, delta * LERP_SPEED)
	rotation.y = lerp_angle(rotation.y, target_rot_y, delta * LERP_SPEED)
	rotation.x = lerp_angle(rotation.x, target_rot_x, delta * LERP_SPEED)
	fov = lerp(fov, target_fov, delta * LERP_SPEED)
	
	# Handle new center movement
	if new_center_bool:
		target_pos = Vector3(center.x, position.y, position.z)
		_apply_snap()
		if position.distance_to(target_pos) < 0.05:
			new_center_bool = false
			_apply_snap()

func snap_left():
	snap_index = (snap_index + 1) % CAMERA_SNAP_COUNT
	_apply_snap()


func snap_right():
	snap_index = (snap_index - 1 + CAMERA_SNAP_COUNT) % CAMERA_SNAP_COUNT
	_apply_snap()

func _apply_snap():
	#this is logic just for if we are in the triple threat room or the tower because custom code yaayyyyyyy
	if center != Vector3.ZERO:
		center_based_apply_snap()
		return
	if wall_view:
		var fov_effect_horizontal = camera_wall_size_effect_horizontal * 4
		var fov_effect_vertical = camera_wall_size_effect_vertical * 4
		var position_effect_vertical = camera_wall_size_effect_vertical
		var position_effect_horizontal = camera_wall_size_effect_horizontal

		match snap_positions[snap_index]["name"]:
			"front":
				target_fov = 75 + (fov_effect_vertical if !triplethreat else 0)
				target_pos = WALL_VIEW_POS + (Vector3(0, 0, -position_effect_horizontal) if !triplethreat else Vector3.ZERO)
			"back":
				target_fov = 75 + (fov_effect_vertical if !triplethreat else 0)
				target_pos = WALL_VIEW_POS + (Vector3(0, 0, position_effect_horizontal) if !triplethreat else Vector3.ZERO)
			"left":
				target_fov = 75 + (fov_effect_horizontal if !triplethreat else 0)
				target_pos = WALL_VIEW_POS + (Vector3(position_effect_vertical, 0, 0) if !triplethreat else Vector3.ZERO)
			"right":
				target_fov = 75 + (fov_effect_horizontal if !triplethreat else 0)
				target_pos = WALL_VIEW_POS + (Vector3(-position_effect_vertical, 0, 0) if !triplethreat else Vector3.ZERO)

		target_rot_x = WALL_VIEW_TILT
	else:
		var base_pos = snap_positions[snap_index]["pos"]
		var position_effect_vertical = camera_wall_size_effect_vertical
		var position_effect_horizontal = camera_wall_size_effect_horizontal

		match snap_positions[snap_index]["name"]:
			"front":
				target_pos = base_pos + (Vector3(0, 0, position_effect_horizontal) if !triplethreat else Vector3.ZERO)
			"back":
				target_pos = base_pos + (Vector3(0, 0, -position_effect_horizontal) if !triplethreat else Vector3.ZERO)
			"left":
				target_pos = base_pos + (Vector3(-position_effect_vertical, 0, 0) if !triplethreat else Vector3.ZERO)
			"right":
				target_pos = base_pos + (Vector3(position_effect_vertical, 0, 0) if !triplethreat else Vector3.ZERO)

		target_rot_x = CAMERA_TILT_ANGLE
		target_fov = 75.0

	target_rot_y = snap_positions[snap_index]["rot"]



func wall_update(enabled: bool) -> void:
	wall_view = enabled
	if center != Vector3.ZERO:
		center_based_wall_update()
		return

	if wall_view:
		var fov_effect_horizontal = camera_wall_size_effect_horizontal * 4
		var fov_effect_vertical = camera_wall_size_effect_vertical * 4
		var position_effect_vertical = camera_wall_size_effect_vertical
		var position_effect_horizontal = camera_wall_size_effect_horizontal

		match snap_positions[snap_index]["name"]:
			"front":
				target_fov = 75 + (fov_effect_vertical if !triplethreat else 10)
				target_pos = WALL_VIEW_POS + (Vector3(0, 0, -position_effect_horizontal) if !triplethreat else Vector3.ZERO)
			"back":
				target_fov = 75 + (fov_effect_vertical if !triplethreat else 10)
				target_pos = WALL_VIEW_POS + (Vector3(0, 0, position_effect_horizontal) if !triplethreat else Vector3.ZERO)
			"left":
				target_fov = 75 + (fov_effect_horizontal if !triplethreat else 10)
				target_pos = WALL_VIEW_POS + (Vector3(position_effect_vertical, 0, 0) if !triplethreat else Vector3.ZERO)
			"right":
				target_fov = 75 + (fov_effect_horizontal if !triplethreat else 10)
				target_pos = WALL_VIEW_POS + (Vector3(-position_effect_vertical, 0, 0) if !triplethreat else Vector3.ZERO)

		target_rot_x = WALL_VIEW_TILT

	else:
		var base_pos = snap_positions[snap_index]["pos"]
		var position_effect_vertical = camera_wall_size_effect_vertical
		var position_effect_horizontal = camera_wall_size_effect_horizontal

		match snap_positions[snap_index]["name"]:
			"front":
				target_pos = base_pos + (Vector3(0, 0, position_effect_horizontal) if !triplethreat else Vector3.ZERO)
			"back":
				target_pos = base_pos + (Vector3(0, 0, -position_effect_horizontal) if !triplethreat else Vector3.ZERO)
			"left":
				target_pos = base_pos + (Vector3(-position_effect_vertical, 0, 0) if !triplethreat else Vector3.ZERO)
			"right":
				target_pos = base_pos + (Vector3(position_effect_vertical, 0, 0) if !triplethreat else Vector3.ZERO)

		target_rot_x = CAMERA_TILT_ANGLE
		target_fov = 75.0

	target_rot_y = snap_positions[snap_index]["rot"]
	
#this is code specifcally for the triple threat room and the tower.

func set_center(new_center: Vector3):
	center = new_center
	new_center_bool = true
	
func center_based_apply_snap():
	if wall_view:
		match snap_positions[snap_index]["name"]:
			"front":
				target_fov = 75
				target_pos = WALL_VIEW_POS + Vector3(center.x, 0, 0)
			"back":
				target_fov = 75
				target_pos = WALL_VIEW_POS + Vector3(center.x, 0, 0)
			"left":
				target_fov = 75
				target_pos = WALL_VIEW_POS + Vector3(center.x, 0, 0)
			"right":
				target_fov = 75
				target_pos = WALL_VIEW_POS + Vector3(center.x, 0, 0)

		target_rot_x = WALL_VIEW_TILT
	else:
		var base_pos = snap_positions[snap_index]["pos"]

		match snap_positions[snap_index]["name"]:
			"front":
				target_pos = base_pos + Vector3(center.x, 0, 5)
			"back":
				target_pos = base_pos + Vector3(center.x, 0, -5)
			"left":
				target_pos = base_pos + Vector3(center.x - 5, 0, 0)
			"right":
				target_pos = base_pos + Vector3(center.x + 5, 0, 0)

		target_rot_x = CAMERA_TILT_ANGLE
		target_fov = 75.0

	target_rot_y = snap_positions[snap_index]["rot"]
	
func center_based_wall_update():
	if wall_view:
		match snap_positions[snap_index]["name"]:
			"front":
				target_fov = 75
				target_pos = WALL_VIEW_POS + Vector3(center.x, 0, 0)
			"back":
				target_fov = 75
				target_pos = WALL_VIEW_POS + Vector3(center.x, 0, 0)
			"left":
				target_fov = 75
				target_pos = WALL_VIEW_POS + Vector3(center.x, 0, 0)
			"right":
				target_fov = 75
				target_pos = WALL_VIEW_POS + Vector3(center.x, 0, 0)

		target_rot_x = WALL_VIEW_TILT
	else:
		var base_pos = snap_positions[snap_index]["pos"]

		match snap_positions[snap_index]["name"]:
			"front":
				target_pos = base_pos + Vector3(center.x, 0, 5)
			"back":
				target_pos = base_pos + Vector3(center.x, 0, -5)
			"left":
				target_pos = base_pos + Vector3(center.x - 5, 0, 0)
			"right":
				target_pos = base_pos + Vector3(center.x + 5, 0, 0)

		target_rot_x = CAMERA_TILT_ANGLE
		target_fov = 75.0

	target_rot_y = snap_positions[snap_index]["rot"]
