@tool
extends EditorScript

var final_models := "res://Models/Final Models/"

func _run():
	add_wall_ray_to_wall_objects()
		
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
	
func create_texture_folders():
	var dir := DirAccess.open(final_models)
	if not dir:
		push_error("Could not open: %s" % final_models)
		return
	
	dir.list_dir_begin()
	var file_name = dir.get_next()
	
	while file_name != "":
		if file_name.ends_with(".tscn"):
			var scene_name := file_name.get_basename()  # strips extension only
			var texture_folder_path := final_models + scene_name + "Textures"
			
			# Create the folder if it doesn't already exist
			if not DirAccess.dir_exists_absolute(texture_folder_path):
				var result := DirAccess.make_dir_absolute(texture_folder_path)
				if result == OK:
					print("Created folder:", texture_folder_path)
				else:
					push_error("Failed to create folder: %s" % texture_folder_path)
			else:
				print("Folder already exists:", texture_folder_path)
		
		file_name = dir.get_next()
	dir.list_dir_end()

func delete_textures_in_folder():
	var dir := DirAccess.open(final_models)
	if not dir:
		push_error("Could not open: %s" % final_models)
		return
	
	dir.list_dir_begin()
	var file_name = dir.get_next()
	
	while file_name != "":
		if dir.current_is_dir() and "Textures" in file_name:
			var textures_path = final_models + file_name + "/"
			var tex_dir := DirAccess.open(textures_path)
			if tex_dir:
				tex_dir.list_dir_begin()
				var tex_file := tex_dir.get_next()
				while tex_file != "":
					# Skip subfolders and keep only files (like .png, .jpg, etc.)
					if not tex_dir.current_is_dir():
						var delete_path = textures_path + tex_file
						var result := DirAccess.remove_absolute(delete_path)
						if result == OK:
							print("Deleted:", delete_path)
						else:
							push_error("Failed to delete: %s" % delete_path)
					tex_file = tex_dir.get_next()
				tex_dir.list_dir_end()
		file_name = dir.get_next()
	dir.list_dir_end()
	
func create_materials():
	var dir := DirAccess.open(final_models)
	if not dir:
		push_error("Could not open: %s" % final_models)
		return
	
	dir.list_dir_begin()
	var file_name = dir.get_next()
	
	while file_name != "":
		if dir.current_is_dir() and "Textures" in file_name:
			var textures_path = final_models + file_name + "/"
			var tex_dir := DirAccess.open(textures_path)
			if tex_dir:
				tex_dir.list_dir_begin()
				var tex_file := tex_dir.get_next()
				while tex_file != "":
					if(tex_file.ends_with(".png")):
						var separator_char = "_"
						var char_index = tex_file.find(separator_char)
						if char_index != -1:
							var part_before_char = tex_file.substr(0, char_index)
							var number = tex_file.substr(tex_file.length()-5, 1)
							var material_name = ""
							if number.is_valid_int():
								material_name = part_before_char + number
							else:
								material_name = part_before_char + "0"
							
							#if the tex_file is a Alb I am going to create the material and assigning the albedo to it
							#if its a normal I am going to assign the normal to it.
							if tex_file.contains("Alb"):
								var save_path = textures_path + material_name + ".tres"
								if !FileAccess.file_exists(save_path):
									var new_material = StandardMaterial3D.new()
									new_material.resource_name = material_name
									var tex_path = textures_path + tex_file
									new_material.albedo_texture = load(tex_path)
									var nrm_path = tex_path.replace("Alb", "Nrm")
									new_material.normal_enabled = true
									new_material.normal_texture = load(nrm_path)
									ResourceSaver.save(new_material, save_path)
								
					tex_file = tex_dir.get_next()
				tex_dir.list_dir_end()
		file_name = dir.get_next()
	dir.list_dir_end()
	
func assign_materials_to_objects():
	var dir := DirAccess.open(final_models)
	if not dir:
		push_error("Could not open: %s" % final_models)
		return
	
	dir.list_dir_begin()
	var file_name = dir.get_next()
	var counter = 0
	while file_name != "" and counter < 5:
		if file_name.ends_with(".tscn"):
			var file_path = final_models + file_name
			var texture_path = file_path.replace(".tscn", "Textures")
			print(texture_path)
			var packed_scene = load(file_path)
			var scene_root = packed_scene.instantiate()
			for child in scene_root.get_children():
				var separator_char = "__"
				var char_index = child.name.find(separator_char)
				var part_after_char = child.name.substr(char_index + 2, child.name.length())
				var texture_name = part_after_char + "0.tres"
				var material_path = texture_path + "/" + texture_name
				var material = load(material_path)
				child.set_surface_override_material(0, material)
				
				
			var result = packed_scene.pack(scene_root)
			result = ResourceSaver.save(packed_scene, file_path)
			counter += 1
		file_name = dir.get_next()
	dir.list_dir_end()

func add_areas_to_object():
	var dir := DirAccess.open(final_models)
	if not dir:
		push_error("Could not open: %s" % final_models)
		return
	
	dir.list_dir_begin()
	var file_name = dir.get_next()
	var counter := 0
	
	while file_name != "":
		if counter < 11:
			counter += 1
			continue
		if file_name.ends_with(".tscn"):
			var file_path = final_models + file_name
			var packed_scene: PackedScene = load(file_path)
			var scene_root: Node = packed_scene.instantiate()
			var chosen_index := 0

			# Choose the correct mesh node
			for i in range(scene_root.get_child_count()):
				var child = scene_root.get_child(i)
				if "mBody" in child.name and "mReBody" not in scene_root.get_child(chosen_index).name:
					chosen_index = i
				if "mReBody" in child.name:
					chosen_index = i
					break

			var target: Node3D = scene_root.get_child(chosen_index)

			# Compute bounding box (local space)
			var bounds: AABB = target.get_aabb()
			var center: Vector3 = bounds.get_center()
			var half_size: Vector3 = bounds.size * 0.5

			# Shared box shape
			var box := BoxShape3D.new()
			box.extents = half_size

			# --- CollisionShape for StaticBody ---
			var static_body := StaticBody3D.new()
			var static_shape := CollisionShape3D.new()
			static_shape.shape = box.duplicate()
			static_shape.position = center
			static_body.add_child(static_shape)
			target.add_child(static_body)
			static_body.owner = scene_root
			static_shape.owner = scene_root

			# --- Area3D + CollisionShape ---
			var area_box := Area3D.new()
			var area_shape := CollisionShape3D.new()
			area_shape.shape = box.duplicate()
			area_shape.position = center
			area_box.add_child(area_shape)
			target.add_child(area_box)
			area_box.owner = scene_root
			area_shape.owner = scene_root

			# Save updated scene
			var new_scene := PackedScene.new()
			if new_scene.pack(scene_root) == OK:
				var err := ResourceSaver.save(new_scene, file_path)
				if err != OK:
					push_error("Failed to save: %s" % file_path)
			else:
				push_error("Failed to pack: %s" % file_path)

			counter += 1
		file_name = dir.get_next()
	
	dir.list_dir_end()


func attach_script():
	var dir := DirAccess.open(final_models)
	if not dir:
		push_error("Could not open: %s" % final_models)
		return

	dir.list_dir_begin()
	var file_name = dir.get_next()

	while file_name != "":
		if file_name.ends_with(".tscn"):
			var file_path = final_models + file_name
			var loaded_scene: PackedScene = load(file_path)
			var scene_root: Node = loaded_scene.instantiate()

			# 1. Attach the script
			var object_script: Script = load("res://Models/Scripts/object_script.gd")
			scene_root.set_script(object_script)

			# 2. Find area node and store its NodePath (not the Node itself)
			var area_node: Node = null
			for i in range(scene_root.get_child_count()):
				var child = scene_root.get_child(i)
				if child.get_child_count() > 0:
					area_node = child.get_child(1)
					break
			if area_node:
				# Make sure your script has: @export var area_path: NodePath
				scene_root.set("area_path", scene_root.get_path_to(area_node))

			# 3. Pack into a NEW PackedScene
			var new_scene := PackedScene.new()
			if new_scene.pack(scene_root) == OK:
				var save_result = ResourceSaver.save(new_scene, file_path)
				if save_result != OK:
					push_error("Failed to save scene: %s" % file_path)
			else:
				push_error("Failed to pack scene: %s" % file_path)
				
		file_name = dir.get_next()

	dir.list_dir_end()
	
func change_collision_layers():
	var dir := DirAccess.open(final_models)
	if not dir:
		push_error("Could not open: %s" % final_models)
		return

	dir.list_dir_begin()
	var file_name = dir.get_next()

	while file_name != "":
		if file_name.ends_with(".tscn"):
			var file_path = final_models + file_name
			var loaded_scene: PackedScene = load(file_path)
			var scene_root: Node = loaded_scene.instantiate()

			var collision_node: StaticBody3D = null
			for i in range(scene_root.get_child_count()):
				var child = scene_root.get_child(i)
				if child.get_child_count() > 0:
					collision_node = child.get_child(0)
					break
			if collision_node:
				collision_node.set_collision_layer_value(1, false)
				collision_node.set_collision_layer_value(3, true)
				collision_node.set_collision_layer_value(8, true)
				collision_node.set_collision_mask_value(1, false)
				collision_node.set_collision_mask_value(3, true)
				collision_node.set_collision_mask_value(8, true)

			var new_scene := PackedScene.new()
			if new_scene.pack(scene_root) == OK:
				var save_result = ResourceSaver.save(new_scene, file_path)
				if save_result != OK:
					push_error("Failed to save scene: %s" % file_path)
			else:
				push_error("Failed to pack scene: %s" % file_path)
				
		file_name = dir.get_next()

	dir.list_dir_end()
	
func change_size_of_object():
	var dir := DirAccess.open(final_models)
	if not dir:
		push_error("Could not open: %s" % final_models)
		return

	dir.list_dir_begin()
	var file_name = dir.get_next()

	while file_name != "":
		if file_name.ends_with(".tscn"):
			var file_path = final_models + file_name
			var loaded_scene: PackedScene = load(file_path)
			var scene_root: Node = loaded_scene.instantiate()
			
			scene_root.scale = Vector3(28,28,28)

			var new_scene := PackedScene.new()
			if new_scene.pack(scene_root) == OK:
				var save_result = ResourceSaver.save(new_scene, file_path)
				if save_result != OK:
					push_error("Failed to save scene: %s" % file_path)
			else:
				push_error("Failed to pack scene: %s" % file_path)
				
		file_name = dir.get_next()

	dir.list_dir_end()
	
func add_icons_to_tab_container():
	var tab_container_path = "res://UI_Overlay/Components/Tab Select.tscn"
	var loaded_scene: PackedScene = load(tab_container_path)
	var scene_root: TabContainer = loaded_scene.instantiate()
	
	scene_root.set_tab_button_icon(0, load("res://UI_Overlay/Sprites/Navigation/FurnitureIcon.png"))
	scene_root.set_tab_button_icon(1, load("res://UI_Overlay/Sprites/Navigation/WallHangableIcon.png"))
	
	var new_scene := PackedScene.new()
	if new_scene.pack(scene_root) == OK:
		var save_result = ResourceSaver.save(new_scene, tab_container_path)
		if save_result != OK:
			push_error("Failed to save scene: %s" % tab_container_path)
	else:
		push_error("Failed to pack scene: %s" % tab_container_path)
		
func add_wall_ray_to_wall_objects():
	var wall_ray_scene = preload("res://Models/wall_ray.tscn")

	var wall_objects := {
		# Clocks
		"Regular Clock": "res://Models/Final Models/FtrClockWall.tscn",
		"Boy Clock": "res://Models/Final Models/FtrBoyClockWall.tscn",
		"Cuckoo Clock": "res://Models/Final Models/FtrCuckooclock.tscn",

		# Pictures and frames
		"Bromide Frame": "res://Models/Final Models/FtrBromideFrameWall.tscn",
		"Plant Frame": "res://Models/Final Models/FtrPlantWall.tscn",
		"Art 1": "res://Models/Final Models/FtrArtBarFB.tscn",
		"Art 2": "res://Models/Final Models/FtrArtBirthVenus.tscn",
		"Art 3": "res://Models/Final Models/FtrArtBlueBoy.tscn",
		"Art 4": "res://Models/Final Models/FtrArtFightingTemeraire.tscn",
		"Art 5": "res://Models/Final Models/FtrArtHunterSnow.tscn",
		"Art 6": "res://Models/Final Models/FtrArtIsleOfDead.tscn",
		"Art 7": "res://Models/Final Models/FtrArtKanagawaOki.tscn",
		"Art 8": "res://Models/Final Models/FtrArtLasMeninas.tscn",
		"Art 9": "res://Models/Final Models/FtrArtMilkmaidFake.tscn",
		"Art 10": "res://Models/Final Models/FtrArtMonaLisa.tscn",
		"Art 11": "res://Models/Final Models/FtrArtVitruvianMan.tscn",
		"Art 12": "res://Models/Final Models/FtrArtSundayOn.tscn",

		# Shelves
		"Stuffy Shelf": "res://Models/Final Models/FtrDreamyShelfW.tscn",
		"Hanging Shelf": "res://Models/Final Models/FtrHangingShelfCeiling.tscn",
		"Iron Shelf": "res://Models/Final Models/FtrIronShelfW.tscn",
		"Log Shelf": "res://Models/Final Models/FtrLogShelf.tscn",
		"Wood Open Shelf": "res://Models/Final Models/FtrOpenshelfWood.tscn",
		"Wood Box Shelf": "res://Models/Final Models/FtrSimpleShelfWall.tscn",
		"Wood Shelf": "res://Models/Final Models/FtrWoodShelfWall.tscn",

		# Misc
		"Dried Flowers": "res://Models/Final Models/FtrDriedflowerWall.tscn",
		"Fan Wall": "res://Models/Final Models/FtrFanRetroWall.tscn",
		"Leaf Wall": "res://Models/Final Models/FtrLeafWall.tscn",
		"TV 20 inch": "res://Models/Final Models/FtrTV20inchWall.tscn",
		"TV 50 inch": "res://Models/Final Models/FtrTV50inchWall.tscn"
	}

	for name in wall_objects.keys():
		var path = wall_objects[name]
		print("Processing: ", name, " -> ", path)

		var packed_scene: PackedScene = load(path)
		if packed_scene == null:
			push_error("Failed to load: %s" % path)
			continue

		var scene_root: Node3D = packed_scene.instantiate()
		if scene_root == null:
			push_error("Failed to instantiate scene: %s" % path)
			continue

		# Add wall_ray to root
		var wall_ray_instance = wall_ray_scene.instantiate()
		scene_root.add_child(wall_ray_instance)
		wall_ray_instance.owner = scene_root

		# Save updated scene
		var updated_scene := PackedScene.new()
		if updated_scene.pack(scene_root) != OK:
			push_error("Failed to pack updated scene for: %s" % path)
			continue

		var result = ResourceSaver.save(updated_scene, path)
		if result != OK:
			push_error("Failed to save updated scene: %s" % path)
		else:
			print("✅ Added wall_ray to: ", name)
