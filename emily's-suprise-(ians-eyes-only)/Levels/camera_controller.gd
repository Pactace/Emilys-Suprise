extends Camera3D

var snap_index := 0
var snap_positions = [
	{ "pos": Vector3(0, 10, 15),  "rot": deg_to_rad(0), "name": "front" },
	{ "pos": Vector3(-15, 10, 0), "rot": deg_to_rad(-90), "name": "left" },
	{ "pos": Vector3(0, 10, -15), "rot": deg_to_rad(-180), "name": "back"},
	{ "pos": Vector3(15, 10, 0),  "rot": deg_to_rad(90), "name": "right"  }
]

var target_pos: Vector3
var target_rot_y: float

#Reminder: Bigger means faster
var lerp_speed := 5.0

func _ready():
	target_pos = position
	target_rot_y = rotation.y

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("Camera Snap Left"):
		snap_left()
	elif Input.is_action_just_pressed("Camera Snap Right"):
		snap_right()

	# Smoothly interpolate
	position = position.lerp(target_pos, delta * lerp_speed)
	rotation.y = lerp_angle(rotation.y, target_rot_y, delta * lerp_speed)

func snap_left():
	snap_index = (snap_index + 1) % 4
	_apply_snap()

func snap_right():
	snap_index = (snap_index - 1 + 4) % 4
	_apply_snap()

func _apply_snap():
	target_pos = snap_positions[snap_index]["pos"]
	target_rot_y = snap_positions[snap_index]["rot"]
