extends Node3D

@export var speed: float = 3.0
@export var intensity: float = 0.5
@export var drive_speed: float = 5.0
@export var start_delay: float = 1.0
@export var exit := false
@onready var transition_screen = $"../TransitionScreen"

var base_scale: Vector3
var elapsed := 0.0
var started := false

func _ready() -> void:
	base_scale = scale
	$AudioStreamPlayer3D.play(12)

func _process(delta: float) -> void:
	elapsed += delta

	# Wait for the pause before starting
	if not started:
		if elapsed >= start_delay:
			started = true
		else:
			return  # Still waiting at the beginning
			
	if elapsed >= 5:
		$AudioStreamPlayer3D.stop()
		$MeshInstance3D.rotate_y(deg_to_rad(90))
	# Car squash/stretch effect
	if position.x < -3.0:
		position.x += drive_speed * delta / (1/abs(position.x + 3.0))/3
