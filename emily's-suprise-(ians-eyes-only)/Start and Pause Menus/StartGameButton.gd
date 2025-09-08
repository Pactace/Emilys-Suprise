extends Button


func _ready() -> void:
	grab_focus()

func _on_pressed() -> void:
	get_tree().change_scene_to_file("res://Levels/Level Scenes/Floor 1/Entry Way.tscn")
