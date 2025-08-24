extends Area3D

@export_file("*.tscn") var connected_door: String
	
func _on_body_entered(body: Node3D) -> void:
	print(connected_door)
	if body.name == "Emily":
		get_tree().change_scene_to_file(connected_door)
