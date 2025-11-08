extends ColorRect

@export var reveal_speed := 1.0  # how fast the circle grows/shrinks
@export var next_scene: String
var circle_size := 0.0
var enter := true
var exit := false

func _ready() -> void:
	# Make sure the shader has the correct screen dimensions
	material.set_shader_parameter("screen_width", get_viewport_rect().size.x)
	material.set_shader_parameter("screen_height", get_viewport_rect().size.y)
	material.set_shader_parameter("circle_size", circle_size)
	enter = true
	exit = false

func _process(delta: float) -> void:
	# ENTER ANIMATION (growing circle)
	if enter:
		if circle_size < 1.05:
			circle_size += delta * reveal_speed
			material.set_shader_parameter("circle_size", circle_size)
		else:
			enter = false  # stop when fully revealed

	if exit:
		if circle_size > 0.0:
			circle_size -= delta * reveal_speed
			material.set_shader_parameter("circle_size", circle_size)
		else:
			exit = false
			if get_tree().current_scene.has_method("save_state"):
				get_tree().current_scene.save_state()
			else:
				push_warning("Current scene has no save_state() method.")
			
			if next_scene != "":
				await get_tree().create_timer(0.2).timeout  # small buffer
				get_tree().change_scene_to_file(next_scene)
