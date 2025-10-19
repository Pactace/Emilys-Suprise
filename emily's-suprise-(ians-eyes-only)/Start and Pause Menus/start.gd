extends RichTextLabel

var time_passed := 0.0
var fade_in_progress := 0.0
@export var blink_speed := 3.0
@export var fade_in_speed := 1.0  # lower = slower fade-in

func _ready() -> void:
	modulate.a = 0.0

func _process(delta: float) -> void:
	if visible:
		# Handle fade-in first
		if fade_in_progress < 1.0:
			fade_in_progress = min(fade_in_progress + delta * fade_in_speed, 1.0)
			modulate.a = fade_in_progress
		else:
			# After fade-in, start gentle pulsing
			time_passed += delta
			modulate.a = 0.5 + 0.5 * sin(time_passed * blink_speed)  # soft pulse (0.6–1.0 range)
	else:
		# Reset when hidden again
		modulate.a = 0.0
		fade_in_progress = 0.0
		time_passed = 0.0
