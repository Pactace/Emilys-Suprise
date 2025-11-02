extends VBoxContainer

var mesh_skins = []
var num_of_skins: int
var instance: Node3D
var mesh_index: int

func increase():
	var count: int = get_child(1).text.to_int()
	count = (count % num_of_skins) + 1
	get_child(1).text = str(count)
	instance.change_colors(mesh_index, (mesh_skins[count-1]))
	

func decrease():
	var count: int = get_child(1).text.to_int()
	count = ((count - 2 + num_of_skins) % num_of_skins) + 1
	get_child(1).text = str(count)
	instance.change_colors(mesh_index, (mesh_skins[count-1]))
