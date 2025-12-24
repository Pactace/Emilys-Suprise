extends GridContainer

@export var tab_name: String = ""
@export var nav_delay: float = 0.2  # seconds between moves
@export var inventory: Resource     # assign .tres in Inspector
@export var visible_rows: int = 5   # number of rows visible at a time
@export var row_height: int = 60    # pixel height per row (adjust if needed)

var is_wall: bool = false
var selected_object: Control = null
var selected_row: int = 0
var selected_col: int = 0
var can_navigate: bool = true
var object_dict: Dictionary = {}
var inventory_set: bool = false
var scroll_container: ScrollContainer
var resource_cache := {}  # cache for loaded scenes/materials
var in_reasource_cache := false


func _ready() -> void:
	while !inventory_set:
		await get_tree().create_timer(2).timeout

	get_parent().name = tab_name
	
	if inventory:
		object_dict = inventory.objects
		load_objects(object_dict)

	# Initialize selection
	var grid = get_children_grid()
	if grid.size() > 0 and grid[0].size() > 0:
		selected_object = grid[0][0]
		highlight_selection(selected_object)

	scroll_container = get_parent()


func _unhandled_input(event: InputEvent) -> void:
	if not (get_parent().visible and get_parent().get_parent().visible):
		return
	if not can_navigate:
		return
		
	var grid = get_children_grid()
	if grid.is_empty():
		return

	var row_count = grid.size()
	var moved = false

	if event.is_action_pressed("Up"):
		selected_row = max(0, selected_row - 1)
		moved = true

	elif event.is_action_pressed("Down"):
		selected_row = min(row_count - 1, selected_row + 1)
		moved = true

	elif event.is_action_pressed("Left"):
		selected_col = max(0, selected_col - 1)
		moved = true

	elif event.is_action_pressed("Right"):
		selected_col = min(grid[selected_row].size() - 1, selected_col + 1)
		moved = true
	
	elif event.is_action_pressed("Accept") and selected_object:
		_handle_accept_action()

	if moved:
		get_parent().get_parent().get_parent().get_parent().get_node_or_null("SoundEffectPlayer").play_ui_switch()
		selected_col = clamp(selected_col, 0, grid[selected_row].size() - 1)
		selected_object = grid[selected_row][selected_col]
		highlight_selection(selected_object)
		_update_scroll_position(row_count)

		can_navigate = false
		await get_tree().create_timer(nav_delay).timeout
		can_navigate = true


func _update_scroll_position(row_count: int) -> void:
	if not scroll_container:
		return
	
	var current_scroll = scroll_container.get_v_scroll()
	var start_index = int(current_scroll / row_height)
	var end_index = start_index + visible_rows - 1

	if selected_row > end_index:
		scroll_container.set_v_scroll((selected_row - visible_rows + 1) * row_height)
	elif selected_row < start_index + 1:
		scroll_container.set_v_scroll(selected_row * row_height - 1)


func _handle_accept_action() -> void:
	var parent_root = get_parent().get_parent().get_parent()
	var room = get_parent().get_parent().room

	if tab_name == "Wallpapers":
		var wall_path: String = selected_object.get_meta("scene_path", "")
		if wall_path != "":
			var wall_material: ShaderMaterial = get_resource(wall_path)
			room.change_wallpaper(wall_material, wall_path)

	elif tab_name == "Flooring":
		var floor_path: String = selected_object.get_meta("scene_path", "")
		if floor_path != "":
			var floor_material: StandardMaterial3D = get_resource(floor_path)
			room.change_flooring(floor_material, floor_path)

	else:
		var scene_path: String = selected_object.get_meta("scene_path", "")
		if scene_path != "":
			var packed_scene: PackedScene = get_resource(scene_path)
			if packed_scene:
				parent_root.get_child(4).assign_selected_object(packed_scene, is_wall, in_reasource_cache)
				parent_root.current_state = parent_root.EditState.Edit_Objects
				parent_root.switch_states()
				get_parent().get_parent().get_parent().get_parent().get_node_or_null("SoundEffectPlayer").play_spawn_object()

	in_reasource_cache = false


# Utility: 2D array from GridContainer children
func get_children_grid() -> Array:
	var cols: int = max(columns, 1)
	var children := get_children()
	var grid := []

	for row_start in range(0, children.size(), cols):
		var row := []
		for col in range(cols):
			var idx := row_start + col
			if idx < children.size():
				row.append(children[idx])
		grid.append(row)

	return grid


func highlight_selection(node: Control) -> void:
	var unselected_style: StyleBox = load("res://UI_Overlay/Components/unselected_container_object.tres")
	var selected_style: StyleBox = load("res://UI_Overlay/Components/selected_container_object.tres")

	for child in get_children():
		if child is Panel:
			child.add_theme_stylebox_override("panel", unselected_style)

	if node is Panel:
		node.add_theme_stylebox_override("panel", selected_style)


func load_objects(dict: Dictionary) -> void:
	for child in get_children():
		child.queue_free()
	
	var count :int 
	var i := 0
	for key in dict.keys():
		i+=1
		if count && i > count:
			break
		var panel = Panel.new()
		panel.custom_minimum_size = Vector2(125, 62.5)
		var stylebox: StyleBox = load("res://UI_Overlay/Components/unselected_container_object.tres")
		if stylebox:
			panel.add_theme_stylebox_override("panel", stylebox)

		var icon = TextureRect.new()
		icon.texture = load(key)
		icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		icon.size = Vector2(100, 50)
		icon.position = Vector2(12.5, 10)
		icon.custom_minimum_size = Vector2(100, 50)
		panel.add_child(icon)

		# Store path instead of preloaded scene
		panel.set_meta("scene_path", dict[key])

		add_child(panel)


# Cached resource loader (saves memory + avoids reloading)
func get_resource(path: String) -> Resource:
	if path == "":
		return null
	if resource_cache.has(path):
		in_reasource_cache = true
		return resource_cache[path]
	var res = load(path)
	resource_cache[path] = res
	return res


func _on_tab_container_is_wall_change(state: bool) -> void:
	is_wall = state


func _on_visibility_changed() -> void:
	if inventory:
		object_dict = inventory.objects
		load_objects(object_dict)


func assign_inventory(inventory_script: GDScript):
	inventory.set_script(inventory_script)
	inventory_set = true
	
func clear_cache() -> void:
	for key in resource_cache.keys():
		var res = resource_cache[key]
		if res is Resource:
			res = null  # helps release references
	resource_cache.clear()
	print("🧹 Resource cache cleared.")
