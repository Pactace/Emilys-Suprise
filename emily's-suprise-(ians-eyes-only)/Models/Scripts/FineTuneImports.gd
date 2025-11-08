@tool
extends EditorScript

var final_models := "res://Models/Final Models/"

func _run():
	var root_path := final_models
	_traverse_folders_to_change_type(root_path)

# --- Traverse folders recursively
func _traverse_folders(path: String) -> void:
	var dir := DirAccess.open(path)
	if not dir:
		push_error("Could not open: %s" % path)
		return

	dir.list_dir_begin()
	var file_name := dir.get_next()
	while file_name != "":
		if dir.current_is_dir():
			if file_name != "." and file_name != "..":
				if file_name == "Textures":
					var textures_path = path.path_join(file_name)
					print("🧵 Found Textures folder:", textures_path)
					create_materials(textures_path)
					create_skins(textures_path)
				else:
					_traverse_folders(path.path_join(file_name))
		else:
			if file_name.ends_with(".glb"):
				var glb_scene := path.path_join(file_name)
				var tscn_path := glb_scene.replace(".glb", ".tscn")
				if FileAccess.file_exists(tscn_path):
					print("⏩ Skipping (already exists):", tscn_path)
				else:
					print("📦 Found GLB file:", glb_scene)
					process_glb_scene(glb_scene, tscn_path)
					change_collision_layers(tscn_path)
		file_name = dir.get_next()

	dir.list_dir_end()

# --- Main conversion pipeline
func process_glb_scene(scene_path: String, save_path: String):
	# Load once
	var scene := load(scene_path)
	if not scene:
		push_error("Could not load GLB: %s" % scene_path)
		return
	
	var inst = scene.instantiate()
	if not inst:
		push_error("Could not instantiate: %s" % scene_path)
		return

	# Step 1: Reparent mesh instances
	reparent_mesh_instances(inst)

	# Step 2: Add collision and area boxes
	add_areas_to_scene(inst)
	
	# Step 3: Attach the script and assign the area.
	var object_script: Script = load("res://Models/Scripts/object_script.gd")
	inst.set_script(object_script)

	# 2. Find area node and store its NodePath (not the Node itself)
	var area_node: Node = null
	for i in range(inst.get_child_count()):
		var child = inst.get_child(i)
		if child.get_child_count() > 0:
			area_node = child.get_child(1)
			break
	if area_node:
		# Make sure your script has: @export var area_path: NodePath
		inst.set("area_path", inst.get_path_to(area_node))
		
	inst.scale *= .3
	
	# Step 5 save the packages: Save final packed scene
	var packed := PackedScene.new()
	var ok := packed.pack(inst)
	if ok == OK:
		var err := ResourceSaver.save(packed, save_path)
		if err == OK:
			print("✅ Final scene saved:", save_path)
			remove_glb_imports(scene_path)
		else:
			push_error("❌ Failed to save scene: %s" % save_path)
	else:
		push_error("❌ Failed to pack scene: %s" % scene_path)

# --- Move mesh instances to root and remove Y_UP
func reparent_mesh_instances(inst: Node3D):
	if not inst.has_node("Y_UP"):
		push_error("⚠️ No Y_UP node found, skipping reparent.")
		return
	
	var skeleton_child : Node3D = inst.get_node("Y_UP").get_child(0).get_child(0)
	if not skeleton_child:
		push_error("⚠️ Invalid Y_UP structure.")
		return

	for child : Node3D in skeleton_child.get_children():
		child.reparent(inst)

	inst.get_node("Y_UP").free()
	print("🧩 Reparented meshes and removed Y_UP.")

# --- Add collision and area volumes
func add_areas_to_scene(inst: Node3D):
	print("➕ Adding collision and area shapes...")
	var chosen_index := 0

	# Pick correct mesh node
	for i in range(inst.get_child_count()):
		var child := inst.get_child(i)
		if "mBody" in child.name and not "mReBody" in inst.get_child(chosen_index).name:
			chosen_index = i
		if "mReBody" in child.name:
			chosen_index = i
			break

	var target := inst.get_child(chosen_index)
	if not target or not (target is MeshInstance3D):
		push_error("⚠️ Could not find valid MeshInstance3D.")
		return

	var bounds = target.get_aabb()
	var center = bounds.get_center()
	var half_size = bounds.size * 0.5

	var box := BoxShape3D.new()
	box.extents = half_size

	# StaticBody3D
	var static_body := StaticBody3D.new()
	var static_shape := CollisionShape3D.new()
	static_shape.shape = box.duplicate()
	static_shape.position = center
	static_body.add_child(static_shape)
	target.add_child(static_body)
	static_body.owner = inst
	static_shape.owner = inst

	# Area3D
	var area_box := Area3D.new()
	var area_shape := CollisionShape3D.new()
	area_shape.shape = box.duplicate()
	area_shape.position = center
	area_box.add_child(area_shape)
	target.add_child(area_box)
	area_box.owner = inst
	area_shape.owner = inst

	print("✅ Added collision + area to:", target.name)

func remove_glb_imports(glb_scene_path: String) -> void:
	var dir_path := glb_scene_path.get_base_dir()
	var file_name := glb_scene_path.get_file()

	var dir := DirAccess.open(dir_path)
	if dir:
		var err := dir.remove(file_name)
		if err == OK:
			print("🗑️ Removed:", glb_scene_path)
		else:
			push_error("⚠️ Could not remove GLB: %s (error %d)" % [glb_scene_path, err])
	else:
		push_error("❌ Could not open directory: %s" % dir_path)
		
	var import_path = glb_scene_path.replace(".glb",".glb.import")
	dir_path = import_path.get_base_dir()
	file_name = import_path.get_file()

	dir = DirAccess.open(dir_path)
	if dir:
		var err := dir.remove(file_name)
		if err == OK:
			print("🗑️ Removed:", glb_scene_path)
		else:
			push_error("⚠️ Could not remove GLB IMPORT: %s (error %d)" % [glb_scene_path, err])
	else:
		push_error("❌ Could not open directory: %s" % dir_path)
	
func create_materials(textures_path: String) -> void:
	var tex_dir := DirAccess.open(textures_path)
	if not tex_dir:
		push_error("Could not open textures directory: %s" % textures_path)
		return

	tex_dir.list_dir_begin()
	var tex_file := tex_dir.get_next()

	while tex_file != "":
		if tex_file.ends_with(".png") and tex_file.contains("Alb"):
			# Extract base name and number
			# e.g. "Leaf_Alb2.png" → base="Leaf", num="2"
			var regex := RegEx.new()
			regex.compile("^(.*?)_Alb(\\d*)\\.png$")
			var match := regex.search(tex_file)

			if match:
				var base_name := match.get_string(1)
				var number := match.get_string(2)
				if number == "":
					number = "0"  # No number means 0

				var material_name := base_name + number
				var save_path := textures_path.path_join(material_name + ".tres")

				# Skip if already exists
				if FileAccess.file_exists(save_path):
					tex_file = tex_dir.get_next()
					continue

				# Create and configure material
				var new_material := StandardMaterial3D.new()
				new_material.resource_name = material_name

				var alb_path := textures_path.path_join(tex_file)
				new_material.albedo_texture = load(alb_path)

				# Look for corresponding normal map
				var nrm_file := "Nrm" + number + ".png"
				var nrm_name := base_name + "_" + nrm_file
				var nrm_path := textures_path.path_join(nrm_name)

				if FileAccess.file_exists(nrm_path):
					new_material.normal_enabled = true
					new_material.normal_texture = load(nrm_path)
				else:
					print("⚠️ Missing normal for:", tex_file)

				var result := ResourceSaver.save(new_material, save_path)
				if result == OK:
					print("✅ Created material:", save_path)
				else:
					push_error("Failed to save material: %s" % save_path)
		
		tex_file = tex_dir.get_next()

	tex_dir.list_dir_end()
		
func create_skins(texture_path: String):
	var skins := {}
	
	var dir := DirAccess.open(texture_path)
	
	if not dir:
		push_error("Could not open: %s" % texture_path)
		return
	
	dir.list_dir_begin()
	var file_name := dir.get_next()
	while file_name != "":
		if not dir.current_is_dir() and file_name.ends_with(".tres"):
			# remove extension for prefix detection
			var name_no_ext := file_name.get_basename()
			
			# derive prefix (base name without trailing digits)
			var prefix := name_no_ext.strip_edges().rstrip("0123456789")
			
			# ensure the prefix exists in the dictionary
			if not skins.has(prefix):
				skins[prefix] = []
			
			# load actual resource and append it
			var file_path = texture_path.path_join(file_name)
			var mat = load(file_path)
			if mat:
				skins[prefix].append(mat)
			else:
				push_warning("Could not load: %s" % file_path)
		
		file_name = dir.get_next()
	dir.list_dir_end()
	
	print("✅ Skins dictionary ready:", skins)
	var folder_path := texture_path.get_base_dir()
	var tscn_file = null
	print(folder_path)
	
	dir = DirAccess.open(folder_path)
	
	dir.list_dir_begin()
	file_name = dir.get_next()
	while file_name != "":
		if ".tscn" in file_name:
			tscn_file = file_name
			break
		file_name = dir.get_next()
	dir.list_dir_end()
	folder_path = folder_path.path_join(tscn_file)
	print(folder_path)
	
	# Load once
	var scene := load(folder_path)
	if not scene:
		push_error("Could not load GLB: %s" % folder_path)
		return
	
	var inst = scene.instantiate()
	if not inst:
		push_error("Could not instantiate: %s" % folder_path)
		return

	
	inst.skins = skins
	
	# Step 5 save the packages: Save final packed scene
	var packed := PackedScene.new()
	var ok := packed.pack(inst)
	if ok == OK:
		var err := ResourceSaver.save(packed, folder_path)
		if err == OK:
			print("✅ Skins Saved:", folder_path)
		else:
			push_error("❌ Failed to save skins")
	else:
		push_error("❌ Failed to pack skins")

	
func change_collision_layers(scene_root_path: String):
	var scene := load(scene_root_path)
	var inst = scene.instantiate()
	var collision_node: StaticBody3D = null
	for i in range(inst.get_child_count()):
		var child = inst.get_child(i)
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
	var packed := PackedScene.new()
	var ok := packed.pack(inst)
	if ok == OK:
		var err := ResourceSaver.save(packed, scene_root_path)
		if err == OK:
			print("✅ Final scene saved:")
		else:
			push_error("❌ Failed to save scene")
	else:
		push_error("❌ Failed to pack scene:")
		
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
			
			
func _traverse_folders_to_change_type(path: String) -> void:
	var dir := DirAccess.open(path)
	if not dir:
		push_error("Could not open: %s" % path)
		return

	dir.list_dir_begin()
	var file_name := dir.get_next()
	while file_name != "":
		var full_path := path.path_join(file_name)
		if dir.current_is_dir():
			if file_name not in [".", "..", "Textures", ".import"]:
				_traverse_folders_to_change_type(full_path)
		else:
			if file_name.ends_with(".tscn"):
				if FileAccess.file_exists(full_path):
					_change_to_table(full_path, file_name)
		file_name = dir.get_next()
	dir.list_dir_end()

	dir.list_dir_end()
	
func _change_to_table(path: String, file_name: String) -> void:
	var keywords := [
		"table", "desk", "cabinet", "shelf", "upright",
		"stand", "chest", "dresser", "cupboard", "kitchen",
		"console", "lowboard", "fireplace", "tray"
	]
	var antikeywords := [
		"chair", "window", "tablet"
	]
	
	var lower_name := file_name.to_lower()

	# Skip if any antikeyword appears in the name
	for anti in antikeywords:
		if anti in lower_name:
			return
	
	# Check for desired keywords
	for keyword in keywords:
		if keyword in lower_name:
			var scene := load(path)
			var inst = scene.instantiate()
			
			inst.object_type = 2
			# Step 5 save the packages: Save final packed scene
			var packed := PackedScene.new()
			var ok := packed.pack(inst)
			if ok == OK:
				var err := ResourceSaver.save(packed, path)
				if err == OK:
					print("✅ Final scene saved:", path)
				else:
					push_error("❌ Failed to save scene: %s" % path)
			else:
				push_error("❌ Failed to pack scene: %s" % path)
