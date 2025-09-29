extends TabContainer

var camera: Camera3D
@onready var room: Node3D
var is_wall: bool = false
signal is_wall_change(state: bool)

func enabled():
	visible = true
	if camera.wall_view == true:
		current_tab = 2
		is_wall =  true
	else:
		current_tab = 0

func disabled():
	visible =  false
	is_wall = false
	current_tab = 0

func _ready() -> void:
	current_tab = 0
	var icon1 = load("res://UI_Overlay/Sprites/Navigation/FurnitureIcon-removebg-preview.png")
	var icon2 = load("res://UI_Overlay/Sprites/Navigation/frame (1).png")
	var icon3 = load("res://UI_Overlay/Sprites/Navigation/WallPaper-removebg-preview.png")
	var icon4 = load("res://UI_Overlay/Sprites/Navigation/Flooring.webp")
	var icon5 = load("res://UI_Overlay/Sprites/Navigation/TablePlacable-removebg-preview.png")
	set_tab_icon(0, icon1)
	set_tab_icon(1, icon5)
	set_tab_icon(2, icon2)
	set_tab_icon(3, icon3)
	set_tab_icon(4, icon4)
	set_tab_icon_max_width(0, 50)
	set_tab_icon_max_width(1, 50)
	set_tab_icon_max_width(2, 50)
	set_tab_icon_max_width(3, 50)
	set_tab_icon_max_width(4, 50)

	
func _unhandled_input(event: InputEvent) -> void:
	if visible:
		if event.is_action_pressed("Pad Left"):
			navigate_tabs(false)
		if event.is_action_pressed("Pad Right"):
			navigate_tabs(true)

func navigate_tabs(positive: bool) -> void:
	var direction = 1 if positive else -1
	var count = get_tab_count()
	current_tab = (current_tab + direction + count) % count
	update_is_wall_state()
	
#---Wall specific functions---#
# placing logic and camera logic will be different
# depending on if we are on the wall or not so its important to have these
func update_is_wall_state() -> void:
	var current_tab = get_current_tab_control().name
	var changed = is_wall
	is_wall = (current_tab == "Wall Objects")
	if changed != is_wall:
		update_is_wall_camera(is_wall)
		is_wall_change.emit(is_wall)
		
func update_is_wall_camera(enabled: bool):
	camera.wall_update(enabled)
	
