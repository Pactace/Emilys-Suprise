extends Node3D

var emily_entered = false
var package_opened = false
@export var changing_inventory: Resource
@export var new_items: Resource
@onready var button_prompt = $ButtonPrompt
@onready var camera = $"../Camera"

func _on_check_open_body_entered(body: Node3D) -> void:
	emily_entered = true
	button_prompt.visible = true


func _on_check_open_body_exited(body: Node3D) -> void:
	emily_entered = false
	button_prompt.visible = false
	
func _process(delta: float) -> void:
	if emily_entered and !package_opened:
		var screen_pos = camera.unproject_position(global_transform.origin)
		button_prompt.position = Vector2(screen_pos.x, screen_pos.y - 100)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("Accept") and emily_entered and !package_opened:
		package_opened = true
		button_prompt.visible = false
		for key in new_items.objects:
			changing_inventory.objects[key] = new_items.objects[key]
		
