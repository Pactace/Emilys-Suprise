extends Node3D
class_name RoomSaveSystem

@export var room_name: String = "default_room" # set this in the inspector per room
@export var objects_path: NodePath = ^"Objects" # path to node that holds spawned items

func _ready():
	_load_saved_state()


# ------------------------
# SAVE
# ------------------------
func save_state():
	var packed_scene = PackedScene.new()
	var tscn_path = "user://%s_level.tscn" % room_name
	var json_path = "user://%s_room.json" % room_name

	# --- Try full scene save first ---
	var pack_result = packed_scene.pack(self)
	if pack_result == OK:
		var result = ResourceSaver.save(tscn_path, packed_scene)
		if result == OK:
			print("💾 Saved full scene:", tscn_path)
			return
		else:
			print("⚠️ Couldn't save PackedScene, using JSON fallback.")

	# --- JSON fallback ---
	var objects_parent = get_node(objects_path)
	var data = []
	for obj in objects_parent.get_children():
		if obj.has_meta("scene_path"):
			data.append({
				"scene": obj.get_meta("scene_path"),
				"position": obj.position,
				"rotation": obj.rotation,
				"scale": obj.scale
			})

	var file = FileAccess.open(json_path, FileAccess.WRITE)
	file.store_string(JSON.stringify(data))
	file.close()
	print("💾 Saved JSON for", room_name)
	

# ------------------------
# LOAD
# ------------------------
func _load_saved_state():
	var tscn_path = "user://%s_level.tscn" % room_name
	var json_path = "user://%s_room.json" % room_name

	# Try full PackedScene first
	if FileAccess.file_exists(tscn_path):
		var saved_scene = load(tscn_path)
		if saved_scene:
			print("✅ Loading full saved scene for", room_name)
			var inst = saved_scene.instantiate()
			get_tree().root.add_child(inst)
			get_tree().current_scene = inst
			queue_free()
			return

	# Try JSON fallback
	if FileAccess.file_exists(json_path):
		print("✅ Loading JSON save for", room_name)
		_load_json_objects(json_path)
	else:
		print("⚠️ No saved data found for", room_name)


func _load_json_objects(path: String):
	var file = FileAccess.open(path, FileAccess.READ)
	var data = JSON.parse_string(file.get_as_text())
	var objects_parent = get_node(objects_path)

	for obj_data in data:
		var obj_scene = load(obj_data["scene"])
		if obj_scene:
			var obj = obj_scene.instantiate()
			obj.position = obj_data["position"]
			obj.rotation = obj_data["rotation"]
			obj.scale = obj_data["scale"]
			obj.set_meta("scene_path", obj_data["scene"])
			objects_parent.add_child(obj)

	print("🏡 Rebuilt room:", room_name)
