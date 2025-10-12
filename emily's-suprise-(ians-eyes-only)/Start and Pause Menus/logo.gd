extends AnimatedSprite2D

@export var start_delay: float = 3.0

func _ready() -> void:
	visible = false
	await get_tree().create_timer(start_delay).timeout
	visible = true
	play()

func _process(delta: float) -> void:
	if frame > 120:
		stop()
		frame = 120
