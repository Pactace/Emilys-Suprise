extends GridContainer

@export var tab_name: String = ""
@export var nav_delay: float = 0.2  # seconds between moves
@export var inventory: Resource   # assign .tres in Inspector
var is_wall: bool = false

var selected_object: Control = null
var selected_row: int = 0
var selected_col: int = 0
var can_navigate: bool = true
var object_dict: Dictionary = {} 
var inventory_set: bool =  false  # local copy of the inventory

func _ready() -> void:
	while !inventory_set:
		await get_tree().create_timer(2).timeout
	name = tab_name
	
	# Load from the resource
	if inventory:
		object_dict = inventory.objects
		load_objects(object_dict)

	# Initialize selection if we have children
	var grid = get_children_grid()
	if grid.size() > 0 and grid[0].size() > 0:
		selected_object = grid[0][0]
		highlight_selection(selected_object)


func _unhandled_input(event: InputEvent) -> void:
	if not (visible and get_parent().visible):
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
		if tab_name == "Wallpapers":
			var room = get_parent().room
			var wall_material: ShaderMaterial = selected_object.get_meta("scene", null)
			room.change_wallpaper(wall_material)
		elif tab_name == "Flooring":
			var room = get_parent().room
			var floor_material: StandardMaterial3D = selected_object.get_meta("scene", null)
			room.change_flooring(floor_material)
		else:
			var packed_scene: PackedScene = selected_object.get_meta("scene", null)
			var room = get_parent().room
			if packed_scene:
				var instance = packed_scene.instantiate()
				room.add_object(instance, is_wall)

	if moved:
		# Clamp col if the new row has fewer items
		selected_col = clamp(selected_col, 0, grid[selected_row].size() - 1)

		# Update selection
		selected_object = grid[selected_row][selected_col]
		highlight_selection(selected_object)

		# Lock movement temporarily
		can_navigate = false
		await get_tree().create_timer(nav_delay).timeout
		can_navigate = true


# Build a 2D array from GridContainer’s children
func get_children_grid() -> Array:
	var cols: Variant = max(columns, 1) # number of columns in GridContainer
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
	var selected_style: StyleBox   = load("res://UI_Overlay/Components/selected_container_object.tres")

	for child in get_children():
		if child is Panel:
			# Reset all panels to unselected
			child.add_theme_stylebox_override("panel", unselected_style)

	if node is Panel:
		# Apply selected style
		node.add_theme_stylebox_override("panel", selected_style)


#this loads the dictionaries each object
func load_objects(dict: Dictionary) -> void:
	for child in get_children():
		child.queue_free()

	for key in dict.keys():
		var panel = Panel.new()
		panel.custom_minimum_size = Vector2(125,62.5)
		# Load and assign a StyleBox
		var stylebox: StyleBox = load("res://UI_Overlay/Components/unselected_container_object.tres")
		if stylebox:
			panel.add_theme_stylebox_override("panel", stylebox)  # 'panel' is usually the correct type for Panel
		else:
			print("Failed to load StyleBox: ", key)
		var icon = TextureRect.new()
		icon.texture = load(key)
		icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		icon.size = Vector2(100,50)
		icon.position = Vector2(12.5,10)
		icon.custom_minimum_size = Vector2(100,50)
		panel.add_child(icon)
		panel.set_meta("scene", dict[key])
		
		add_child(panel)


#here we are changing this is_wall state
func _on_tab_container_is_wall_change(state: bool) -> void:
	is_wall = state


func _on_visibility_changed() -> void:
	if inventory:
		object_dict = inventory.objects
		load_objects(object_dict)
		
func assign_inventory(inventory_script: GDScript):
	inventory.set_script(inventory_script)
	inventory_set = true
	
