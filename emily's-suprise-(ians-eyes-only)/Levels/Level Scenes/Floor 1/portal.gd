@tool
extends MeshInstance3D

@onready var fade_away = $"Fade away"
@export var marker: Marker3D
var old_probe_position = Vector3.ZERO

func _physics_process(delta):
	var mat := material_override as ShaderMaterial
	if not mat:
		return
	
	if marker and is_instance_valid(marker) and marker != null:
		# Only update when the marker actually moves
		if old_probe_position != marker.position:
			old_probe_position = marker.position
			fade_away.visible = true
			if name == "Left Wall" or name == "Right Wall":
				fade_away.global_position.z = marker.global_position.z
				fade_away.scale.x = marker.scale.x
			else:
				fade_away.global_position.x = marker.global_position.x
				fade_away.scale.x = marker.scale.x
			print(marker.scale.x)
			mat.set_shader_parameter("center", to_local(marker.global_position))
			mat.set_shader_parameter("scale", marker.scale.x)
	else:
		# Revert to default state when no marker
		mat.set_shader_parameter("center", Vector3.ZERO)
		fade_away.visible = false

func jiggle_marker():
	if marker and is_instance_valid(marker):
		var original_pos = marker.position
		marker.position += Vector3(randf() * 0.001, 0, 0) # Tiny nudge
		await get_tree().process_frame
		marker.position = original_pos
