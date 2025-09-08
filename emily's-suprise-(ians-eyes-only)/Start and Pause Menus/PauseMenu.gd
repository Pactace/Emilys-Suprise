extends Control

@onready var back_to_game_button = $"Back to Game"

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("Pause"):
		get_tree().paused = !get_tree().paused
		visible = !visible
		if visible:
			back_to_game_button.grab_focus()

func _on_back_to_game_pressed() -> void:
	get_tree().paused = false
	visible = false


func _on_quit_pressed() -> void:
		get_tree().paused = false
		get_tree().change_scene_to_file("res://Start and Pause Menus/Main Menu.tscn")
