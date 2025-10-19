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
	$AudioStreamPlayer3D.play(3)

func _process(delta: float) -> void:
	elapsed += delta

	# Wait for the pause before starting
	if not started:
		if elapsed >= start_delay:
			started = true
		else:
			return  # Still waiting at the beginning
			
	if elapsed >= 3:
		$AudioStreamPlayer3D.volume_db = 0.5

	# Car squash/stretch effect
	var t = Time.get_ticks_msec() / 1000.0
	var s = 1.0 + sin(t * speed) * intensity
	scale = Vector3(base_scale.x / s, base_scale.y * s, base_scale.z / s)

	if position.x < 0.0:
		position.x += drive_speed * delta / (1/abs(position.x))/3
		
	if exit:
		position.x += drive_speed * delta * 5
		if position.x > 10.0:
			transition_screen.exit = true
		

func speed_away():
	exit = true
	$AudioStreamPlayer3D.play(3)
	$AudioStreamPlayer3D.volume_db = 5.0
	elapsed = 0
