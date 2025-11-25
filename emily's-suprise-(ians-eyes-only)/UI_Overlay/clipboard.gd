extends Control

@onready var clipboard_icon = $"../ClipboardIcon"
var enabled = true

func _ready() -> void:
	var room_name = get_tree().current_scene.room_name
	if(room_name == "Entryway"):
		get_child(1).text = "This is the first place the\nfather see's when arrivng\nafter a long day of work,\nthe kids after a long day\nof school. and visitors \nafter a long journey \n"
		get_child(3).text = "Make a place that people\ncan feel at home as they\nenter, whether they live\nhere or not"
	elif(room_name == "Office"):
		get_child(1).text = "The mother and father\nboth work from home\nshe needs art tools\nfor her creative work\nthe father needs a gaming\ncomputer and whiteboard\n"
		get_child(3).text = "Make a place that they can\nfeel calm as they work\nthrough the stresses\nof life together"
	elif(room_name == "GuestBathroom"):
		get_child(1).text = "This is the place\nguests use the restroom\nit should be simple\nand compact"
		get_child(3).text = "Make sure they\nhave nice place\nto poop :3"
	elif(room_name == "TripleThreat"):
		get_child(1).text = "This is the place\nthe family spends most\nof their time\ncooking, eating, and\nhanging out in the\n kitchen, dinning room and\nliving room"
		get_child(3).text = "Make sure the family\nhave nice place\n to cook together\neat together, pray, read\nand watch movies together"
	elif(room_name == "Basement"):
		get_child(1).text = "This is the place\nthe kids call there own\nthey hang out\n with friends and\nplay here"
		get_child(3).text = "Make sure the kids\nhave a fun place\n to play"
	
func _process(delta: float) -> void:
	if get_parent().get_parent().current_state == get_parent().get_parent().PlayerState.Moving && enabled == false:
		print(enabled)
		if clipboard_icon.visible:
			clipboard_icon.visible = false
			visible = true  
		else:
			clipboard_icon.visible = true
			visible = false
		enabled = true
	elif enabled == true && get_parent().get_parent().current_state == get_parent().get_parent().PlayerState.Editing:
		enabled = false
		clipboard_icon.visible = false
		visible = false  


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("Toggle Colors & Spacing") && enabled == true:
		if clipboard_icon.visible:
			clipboard_icon.visible = false
			visible = true  
		else:
			clipboard_icon.visible = true
			visible = false  
