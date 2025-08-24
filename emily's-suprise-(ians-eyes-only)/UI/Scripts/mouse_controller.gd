extends Marker2D
@export var SPEED = 7.0
var can_move = false

func _physics_process(delta: float) -> void:
	if can_move:
		var input_dir := Input.get_vector("Left", "Right", "Up", "Down")
		if input_dir != Vector2.ZERO:
			var move = input_dir * SPEED * 100 * delta
			position += move
			position.x = clamp(position.x, 0, get_viewport().size.x)
			position.y = clamp(position.y, 0, get_viewport().size.y)
