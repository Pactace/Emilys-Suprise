extends Camera3D

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
const LERP_SPEED := 5.0  # bigger = faster

# --- Snap State ---
var snap_index := 0
var snap_positions = [
	{ "pos": Vector3(0, CAMERA_HEIGHT, CAMERA_DISTANCE),   "rot": ROT_FRONT, "name": "front" },
	{ "pos": Vector3(-CAMERA_DISTANCE, CAMERA_HEIGHT, 0), "rot": ROT_LEFT,  "name": "left" },
	{ "pos": Vector3(0, CAMERA_HEIGHT, -CAMERA_DISTANCE), "rot": ROT_BACK,  "name": "back"},
	{ "pos": Vector3(CAMERA_DISTANCE, CAMERA_HEIGHT, 0),  "rot": ROT_RIGHT, "name": "right" }
]

# --- State ---
var wall_view : bool = false
var target_pos: Vector3
var target_rot_y: float


func _ready():
	target_pos = position
	target_rot_y = rotation.y


func _process(delta: float) -> void:
	if Input.is_action_just_pressed("Camera Snap Left"):
		snap_left()
	elif Input.is_action_just_pressed("Camera Snap Right"):
		snap_right()

	position = position.lerp(target_pos, delta * LERP_SPEED)
	rotation.y = lerp_angle(rotation.y, target_rot_y, delta * LERP_SPEED)

func snap_left():
	snap_index = (snap_index + 1) % CAMERA_SNAP_COUNT
	_apply_snap()


func snap_right():
	snap_index = (snap_index - 1 + CAMERA_SNAP_COUNT) % CAMERA_SNAP_COUNT
	_apply_snap()


func _apply_snap():
	if wall_view:
		target_pos = WALL_VIEW_POS
		rotation.x = WALL_VIEW_TILT
	else:
		target_pos = snap_positions[snap_index]["pos"]
		rotation.x = CAMERA_TILT_ANGLE

	target_rot_y = snap_positions[snap_index]["rot"]


func wall_update(enabled: bool) -> void:
	wall_view = enabled
	if wall_view:
		target_pos = WALL_VIEW_POS
		rotation.x = WALL_VIEW_TILT
		target_rot_y = snap_positions[snap_index]["rot"]
	else:
		rotation.x = CAMERA_TILT_ANGLE
		target_pos = snap_positions[snap_index]["pos"]
