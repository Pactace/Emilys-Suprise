extends Node3D
class_name RoomSaveSystem

@export var room_name: String = "default_room"
@export var exclude_scenes: Array[String] = [
	"res://Levels/Components/Emily.tscn",
	"res://Levels/Components/music_player.tscn",
	"res://Levels/Components/stairs.tscn"
]  # Permanent children that shouldn't be saved

func _ready():
	print("🏠 Loading saved state for", room_name)
	print(ProjectSettings.globalize_path("user://"))
	_load_saved_state()

# ============================
# SAVE
# ============================
func save_state():
	var path_json := "user://%s_room.json" % room_name
	var data = []
	
	# Iterate through all children (spawned objects)
	for obj in get_children():
		# Skip if not a Node3D (safety check)
		if not obj is Node3D:
			continue
			
		# Try to get the scene file path
		var scene_path = ""
		if obj.has_meta("scene_path"):
			scene_path = obj.get_meta("scene_path")
		elif obj.scene_file_path != "":
			scene_path = obj.scene_file_path
		else:
			print("⚠️ Skipping", obj.name, "- no scene path found")
			continue
		
		var save_data
		# Skip excluded scenes (permanent children)
		if scene_path in exclude_scenes:
			print("⏭️ Skipping excluded scene:", obj.name)
			continue
		if scene_path == "res://Levels/Components/Room.tscn":
				save_data = {
					"wallpaper": obj.wallpaper,
					"flooring": obj.flooring
		}
		else:
			# Build save data
			save_data = {
				"scene": scene_path,
				"position": [obj.position.x, obj.position.y, obj.position.z],
				"rotation": [obj.rotation.x, obj.rotation.y, obj.rotation.z],
				"scale": [obj.scale.x, obj.scale.y, obj.scale.z],
				"on_wall": obj.is_on_wall,
				"object_type": obj.object_type,
				"selected_skins": obj.selected_skins
			}
		
		data.append(save_data)
		print("💾 Saving:", obj.name, "from", scene_path)
	
	if data.is_empty():
		print("⚠️ No objects to save in", room_name)
		return
	
	var file = FileAccess.open(path_json, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(data, "\t"))  # Pretty print with tabs
		file.close()
		print("💾 Saved %d objects to: %s" % [data.size(), path_json])
	else:
		print("❌ Failed to open file for writing:", path_json)

# ============================
# LOAD
# ============================
func _load_saved_state():
	var json_path = "user://%s_room.json" % room_name
	
	if FileAccess.file_exists(json_path):
		print("✅ Found JSON save for", room_name)
		_load_json_objects(json_path)
	else:
		print("⚠️ No saved data for", room_name, "- starting fresh.")

func _load_json_objects(path: String):
	var file = FileAccess.open(path, FileAccess.READ)
	if not file:
		print("❌ Failed to open save file:", path)
		return
	
	var json_text = file.get_as_text()
	file.close()
	
	var data = JSON.parse_string(json_text)
	if not data:
		print("❌ Failed to parse JSON from:", path)
		return
	
	# Load saved objects
	var loaded_count = 0
	for obj_data in data:
		# Check if this is Room data (has flooring/wallpaper keys)
		if obj_data.has("flooring") and obj_data.has("wallpaper"):
			print("has flooring and wallpaper")
			get_child(0).flooring = obj_data["flooring"]
			get_child(0).wallpaper = obj_data["wallpaper"]
			get_child(0).change_wallpaper(load(obj_data["wallpaper"]), obj_data["wallpaper"])
			get_child(0).change_flooring(load(obj_data["flooring"]), obj_data["flooring"])
		else:
			# This is a regular object with a scene path
			var obj_scene = load(obj_data["scene"])
			if obj_scene:
				var obj = obj_scene.instantiate()
				
				# Restore transform
				var pos = obj_data["position"]
				var rot = obj_data["rotation"]
				var scl = obj_data["scale"]
				
				obj.position = Vector3(pos[0], pos[1], pos[2])
				obj.rotation = Vector3(rot[0], rot[1], rot[2])
				obj.scale = Vector3(scl[0], scl[1], scl[2])
				obj.is_on_wall = obj_data["on_wall"]
				obj.object_type = obj_data["object_type"]
				obj.selected_skins = obj_data["selected_skins"]
				
				obj.set_meta("scene_path", obj_data["scene"])
				add_child(obj)
				loaded_count += 1
			else:
				print("⚠️ Failed to load scene:", obj_data["scene"])
	
	print("🏡 Restored %d objects for %s" % [loaded_count, room_name])

# ============================
# HELPER - Call this when spawning new objects
# ============================
func register_spawned_object(obj: Node3D, scene_path: String):
	"""Call this whenever you spawn a new decorative object"""
	obj.set_meta("scene_path", scene_path)
	print("📝 Registered object:", obj.name, "from", scene_path)
