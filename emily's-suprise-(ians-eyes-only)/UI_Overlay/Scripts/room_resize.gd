extends VBoxContainer

#Public variables
var room: Node3D

#Private variables
var vertical_room_size: int = 0
var horizontal_room_size: int = 0

#Children
@onready var vertical_room_size_slider = $HBoxContainer/VBoxContainer/VerticalSliderEdit
@onready var horizontal_room_size_slider = $HBoxContainer2/VBoxContainer/HorizontalSliderEdit

func enabled():
	visible = true
	
func disabled():
	visible = false

func _unhandled_input(event: InputEvent) -> void:
	if visible:
		if event.is_action_pressed("Pad Up") and vertical_room_size < vertical_room_size_slider.max_value:
			vertical_slider_change(true)
		elif event.is_action_pressed("Pad Down") and vertical_room_size > vertical_room_size_slider.min_value:
			vertical_slider_change(false)
		elif event.is_action_pressed("Pad Right") and horizontal_room_size < horizontal_room_size_slider.max_value:
			horizontal_slider_change(true)
		elif event.is_action_pressed("Pad Left") and horizontal_room_size > horizontal_room_size_slider.min_value:
			horizontal_slider_change(false)
	
func vertical_slider_change(positive: bool):
	vertical_room_size += 1 if positive else -1
	vertical_room_size_slider.value = vertical_room_size 
	room.on_vertical_change(vertical_room_size)
	
func horizontal_slider_change(positive: bool):
	horizontal_room_size += 1 if positive else -1
	horizontal_room_size_slider.value = horizontal_room_size 
	room.on_horizontal_change(horizontal_room_size) 
	
