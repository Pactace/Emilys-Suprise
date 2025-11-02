extends Panel

@onready var verticalcontainer = $VBoxContainer
@onready var skin_modifier = $VBoxContainer/HBoxContainer
@export var skin_num : int = 3
var child_selected: int = 0
var instance: Node3D

func onready():
	visible = false
	
func enabled():
	visible = true
	# --- Clear all but one child from verticalcontainer ---
	var children = verticalcontainer.get_children()
	for i in range(1, children.size()): # start at 1, keep the first
		children[i].queue_free()

	# --- Duplicate based on instance children ---
	for i in range(instance.get_child_count() - 1):
		var duplicate_child = skin_modifier.duplicate()
		verticalcontainer.add_child(duplicate_child)
	
	var key = instance.skins.keys()[child_selected]
	verticalcontainer.get_child(child_selected).instance = instance
	verticalcontainer.get_child(child_selected).mesh_skins = instance.skins[key]
	verticalcontainer.get_child(child_selected).num_of_skins = instance.skins[key].size()

func disabled():
	visible = false
	
func _unhandled_input(event: InputEvent) -> void:
	if visible:
		if event.is_action_pressed("Pad Right"):
			child_selected = (child_selected + 1) % verticalcontainer.get_child_count()
			var key = instance.skins.keys()[child_selected]
			verticalcontainer.get_child(child_selected).instance = instance
			verticalcontainer.get_child(child_selected).mesh_skins = instance.skins[key]
			verticalcontainer.get_child(child_selected).num_of_skins = instance.skins[key].size()
			verticalcontainer.get_child(child_selected).mesh_index = child_selected
		if event.is_action_pressed("Pad Left"):
			child_selected = (child_selected - 1) % verticalcontainer.get_child_count()
			var key = instance.skins.keys()[child_selected]
			verticalcontainer.get_child(child_selected).instance = instance
			verticalcontainer.get_child(child_selected).mesh_skins = instance.skins[key]
			verticalcontainer.get_child(child_selected).num_of_skins = instance.skins[key].size()
			verticalcontainer.get_child(child_selected).mesh_index = child_selected
		if event.is_action_pressed("Pad Up"):
			verticalcontainer.get_child(child_selected).increase()
		if event.is_action_pressed("Pad Down"):
			verticalcontainer.get_child(child_selected).decrease()
