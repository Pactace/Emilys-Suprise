extends ColorRect

@export var reveal_speed := 1.0  # how fast the circle grows/shrinks
@export var next_scene: String
var circle_size := 0.0
var enter := true
var exit := false

func _ready() -> void:
	reveal_speed = 1.0
	# Make sure the shader has the correct screen dimensions
	material.set_shader_parameter("screen_width", get_viewport_rect().size.x)
	material.set_shader_parameter("screen_height", get_viewport_rect().size.y)
	material.set_shader_parameter("circle_size", circle_size)
	enter = true

func _process(delta: float) -> void:
	# ENTER ANIMATION (growing circle)
	if enter:
		if circle_size < 1.05:
			circle_size += delta * reveal_speed
			material.set_shader_parameter("circle_size", circle_size)
		else:
			enter = false  # stop when fully revealed

	# EXIT ANIMATION (shrinking circle)
	if exit:
		if circle_size > 0.0:
			circle_size -= delta * reveal_speed
			material.set_shader_parameter("circle_size", circle_size)
		else:
			exit = false  # stop when fully hidden
			if next_scene:
				get_tree().change_scene_to_file(next_scene)
