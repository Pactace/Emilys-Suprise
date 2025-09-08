extends Node3D

var emily_entered = false
var package_opened = false
@export var changing_inventory: Resource
@export var new_items: Resource

func _on_check_open_body_entered(body: Node3D) -> void:
	emily_entered = true


func _on_check_open_body_exited(body: Node3D) -> void:
	emily_entered = false

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("Accept") and emily_entered and !package_opened:
		package_opened = true
		for key in new_items.objects:
			changing_inventory.objects[key] = new_items.objects[key]
			print(changing_inventory.objects)
		
