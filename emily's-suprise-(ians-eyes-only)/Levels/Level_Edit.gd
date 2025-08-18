extends Node3D

func spawn_object(object_name):
	var size: float
	match object_name:
		"Small Object":
			size = 0.5
		"Medium Object":
			size = 1.0
		"Large Object":
			size = 2.0
	
	var box := MeshInstance3D.new()
	var mesh := BoxMesh.new()
	mesh.size = Vector3(size, size, size)
	box.mesh = mesh
	
	box.global_transform.origin = Vector3(0, size / 2.0, 0) 
	
	add_child(box)

func _on_room_edit_spawn_object(object: String) -> void:
	spawn_object(object)
