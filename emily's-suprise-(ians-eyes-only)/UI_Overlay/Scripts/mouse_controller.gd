extends Marker2D
@export var SPEED = 300.0 

func enabled():
	visible = true

func disabled():
	visible = false

func _process(delta: float) -> void:
	if visible:
		var input_dir := Input.get_vector("Left", "Right", "Up", "Down")
		if input_dir != Vector2.ZERO:
			position += input_dir * SPEED * delta
			position.x = clamp(position.x, 0, get_viewport().size.x)
			position.y = clamp(position.y, 0, get_viewport().size.y)
