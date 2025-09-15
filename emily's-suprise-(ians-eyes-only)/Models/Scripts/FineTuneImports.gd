@tool
extends EditorScript

var final_models := "res://Models/Final Models/"

func _run():
	delete_animation_players()

func cleanup():
	var dir := DirAccess.open(final_models)
	if not dir:
		push_error("Could not open: %s" % final_models)
		return
	
	dir.list_dir_begin()
	var file_name = dir.get_next()
	while file_name != "":
		if file_name.ends_with(".fbx"):
			var file_path = final_models + file_name
			print("Processing: ", file_path)
			
			var scene = load(file_path)
			if scene:
				var inst = scene.instantiate()
				
				# Delete any AnimationPlayer nodes
				var anim_players = inst.get_children(true).filter(func(c): return c is AnimationPlayer)
				for ap in anim_players:
					ap.queue_free()
					print("Removed AnimationPlayer from ", file_name)
				
				# Pack into a clean scene
				var packed := PackedScene.new()
				var ok := packed.pack(inst)
				if ok == OK:
					var save_path := final_models + file_name.get_basename() + ".tscn"
					var err = ResourceSaver.save(packed, save_path)
					if err == OK:
						print("Saved scene:", save_path)
					else:
						push_error("Failed to save scene: %s" % save_path)
				else:
					push_error("Failed to pack scene: %s" % file_name)
		
		file_name = dir.get_next()
	dir.list_dir_end()

func delete_fbx_files():
	var dir := DirAccess.open(final_models)
	if not dir:
		push_error("Could not open: %s" % final_models)
		return
	
	dir.list_dir_begin()
	var file_name = dir.get_next()
	while file_name != "":
		if file_name.ends_with(".fbx.import"):
			var file_path = final_models + file_name
			var err = dir.remove(file_name)
			if err == OK:
				print("Deleted:", file_path)
			else:
				push_error("Failed to delete: %s" % file_path)
		file_name = dir.get_next()
	dir.list_dir_end()
	
func delete_animation_players():
	var dir := DirAccess.open(final_models)
	if not dir:
		push_error("Could not open: %s" % final_models)
		return
	
	dir.list_dir_begin()
	var file_name = dir.get_next()
	while file_name != "":
		if file_name.ends_with(".tscn"):
			var file_path = final_models + file_name
			var packed_scene = load(file_path)
			var scene_root = packed_scene.instantiate()
			
			if scene_root.has_node("AnimationPlayer"):
				scene_root.get_node("AnimationPlayer").free()
				var result = packed_scene.pack(scene_root)
				result = ResourceSaver.save(packed_scene, file_path)
		file_name = dir.get_next()
	dir.list_dir_end()
