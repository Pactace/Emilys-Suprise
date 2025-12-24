extends Camera3D

# --- Lerp ---
var LERP_SPEED := 5.0  # bigger = faster

# --- State ---
var target_pos: Vector3

func _ready():
	target_pos = position
	
func _process(delta: float) -> void:
	# Smooth transitions
	position = position.lerp(target_pos, delta * LERP_SPEED)
