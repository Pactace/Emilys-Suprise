extends Control

var selected_item = "null"

func _ready() -> void:
	visible = false

func _on_emily_change_game_state(state: int) -> void:
	if state > 0:
		visible = true
		get_child(1).can_move = true
	else: 
		visible = false
		get_child(1).can_move = false

signal spawn_object(object: String)

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("Accept") and selected_item:
		print(selected_item) 
		spawn_object.emit(selected_item)

func _on_area_2d_area_entered(area: Area2D) -> void:
	selected_item = area.get_parent().name
