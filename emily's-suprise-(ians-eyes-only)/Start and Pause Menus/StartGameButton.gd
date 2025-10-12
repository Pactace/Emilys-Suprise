extends TextureButton


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("Accept") or event.is_action_pressed("+"):
		print("moving to new scene")
