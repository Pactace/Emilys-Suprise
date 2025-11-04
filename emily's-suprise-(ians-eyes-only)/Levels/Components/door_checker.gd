extends Area3D

func _on_body_entered(body: Node3D) -> void:
	# Safely get the body's parent
	var parent = body.get_parent()

	# Check if the parent has a script and if it's door.gd or open_entrance.gd
	if parent and parent.get_script() != null:
		var script_path = parent.get_script().resource_path
		match script_path.get_file():
			"door.gd":
				print("door:", parent.name)
			"open_entrance.gd":
				print("open_entrance:", parent.name)
				parent.enter_portal()
