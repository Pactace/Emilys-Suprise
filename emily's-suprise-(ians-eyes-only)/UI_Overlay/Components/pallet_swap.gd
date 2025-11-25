extends Panel

@onready var verticalcontainer = $VBoxContainer
@onready var skin_modifier = $VBoxContainer/HBoxContainer
@export var skin_num: int = 3
var child_selected: int = 0
var old_child: int = 0
var instance: Node3D

func onready():
	visible = false

func enabled():
	visible = true
	child_selected = 0
	
	# --- Clear all but one child from verticalcontainer ---
	var children = verticalcontainer.get_children()
	for i in range(1, children.size()): # keep the first one
		children[i].queue_free()

	# --- Duplicate based on instance children ---
	if instance and "skins" in instance:
		for i in range(instance.skins.size() - 1):
			var duplicate_child = skin_modifier.duplicate()
			verticalcontainer.add_child(duplicate_child)
		
		for child in verticalcontainer.get_children():
			child.get_child(1).text = str(1)
			child.get_child(1).add_theme_color_override("font_color", Color.WHITE)

		var key = instance.skins.keys()[child_selected]
		var selected_child = verticalcontainer.get_child(child_selected)
		selected_child.instance = instance
		selected_child.mesh_skins = instance.skins[key]
		selected_child.num_of_skins = instance.skins[key].size()
		_change_selection(0)

func disabled():
	visible = false

func _unhandled_input(event: InputEvent) -> void:
	if not visible:
		return
	
	if event.is_action_pressed("Pad Right"):
		_change_selection(1)
	elif event.is_action_pressed("Pad Left"):
		_change_selection(-1)
	elif event.is_action_pressed("Pad Up"):
		_play_sound("play_increase")
		verticalcontainer.get_child(child_selected).increase()
	elif event.is_action_pressed("Pad Down"):
		_play_sound("play_decrease")
		verticalcontainer.get_child(child_selected).decrease()

func _change_selection(direction: int) -> void:
	var total_children = verticalcontainer.get_child_count()
	if total_children == 0:
		return

	child_selected = (child_selected + direction) % total_children
	if child_selected < 0:
		child_selected = total_children - 1

	# Reset old label color
	var old_label = verticalcontainer.get_child(old_child).get_child(1)
	old_label.add_theme_color_override("font_color", Color.WHITE)

	# Update selected child
	var key = instance.skins.keys()[child_selected]
	var selected_child = verticalcontainer.get_child(child_selected)
	selected_child.instance = instance
	selected_child.mesh_skins = instance.skins[key]
	selected_child.num_of_skins = instance.skins[key].size()
	selected_child.mesh_index = child_selected
	old_child = child_selected

	# Highlight new label
	var new_label = selected_child.get_child(1)
	new_label.add_theme_color_override("font_color", Color.AQUA)

func _play_sound(method_name: String) -> void:
	var sfx_player = get_parent().get_parent().get_parent().get_node_or_null("SoundEffectPlayer")
	if sfx_player and sfx_player.has_method(method_name):
		sfx_player.call(method_name)
