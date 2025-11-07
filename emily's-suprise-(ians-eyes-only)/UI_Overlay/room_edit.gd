extends Control

"""
This control node acts as the state machine between the overlay ui elements during runtime.

The UI overlay should consist of these UI mechanics
Room Resize: For making bigger or smaller rooms
Tab Select: For selecting the different item categories and selecting items
Edit Object: For moving around objects

The EditState enum seeks to decide which UI element is going to be selected and which not.
There is also global variables that should be passed to the children here.
"""

#---Scene Elements---#
@export var camera: Camera3D
@export var room : Node3D
@onready var mouse: Marker2D = $Mouse
@onready var edit_object = $EditObject
@onready var room_resize = $RoomResize
@onready var tab_select = $TabSelect
@onready var resize_prompt = $ResizePrompt
@onready var place_prompt = $PlaceObjectsPrompt
@onready var tab_select_prompt = $TabSelectControls

@export var floor_furniture_inventory: GDScript
var flooring_inventory: GDScript = load("res://Inventories/FlooringInventory.gd")
@export var placeable_inventory: GDScript
@export var wall_furniture_inventory: GDScript
@export var wallpaper_inventory: GDScript 

#---Edit State Variables---#
enum EditState {Edit_Objects, Size_Modify, Object_Select}
var current_state: EditState = EditState.Edit_Objects
			
func enabled():
	visible = true
	mouse.enabled()
	switch_states()
	
func disabled():
	visible = false
	
	#this might be subject to change based on play testing
	current_state = EditState.Edit_Objects
	mouse.disabled()
	edit_object.disabled()
	tab_select.disabled()
	room_resize.disabled()
	
	#the wall stuff
	camera.wall_update(false)
	_on_tab_select_is_wall_change(false)

func _ready() -> void:
	#global variables should be assigned by the parent.
	edit_object.mouse = mouse
	room_resize.room = room 
	tab_select.room = room
	tab_select.camera = camera
	edit_object.camera = camera
	assign_tab_select_inventories()
	
	#next we are going to switch states to the default edit object state
	current_state = 0
	

func _unhandled_input(event: InputEvent) -> void:
	if visible:
		#this is for selecting the state
		if event.is_action_pressed("+"):
			if current_state == EditState.Edit_Objects or current_state == EditState.Size_Modify:
				tab_select.enabled()
				room_resize.disabled()
				current_state = EditState.Object_Select
				
			elif current_state == EditState.Object_Select:
				tab_select.disabled()
				current_state = EditState.Edit_Objects
			
			switch_states()
				
		if event.is_action_pressed("-"):
			if current_state == EditState.Edit_Objects or current_state == EditState.Object_Select:
				current_state = EditState.Size_Modify
				
			elif current_state == EditState.Size_Modify:
				current_state = EditState.Edit_Objects
				
			switch_states()
		if event.is_action_pressed("Cancel"):
			if camera.wall_view && current_state != EditState.Edit_Objects:
				camera.wall_update(false)
			current_state = EditState.Edit_Objects
			switch_states()
				
func switch_states():
	edit_object.enabled() if current_state == EditState.Edit_Objects else edit_object.disabled()
	room_resize.enabled() if current_state == EditState.Size_Modify else room_resize.disabled()
	camera.wall_update(false) if current_state == EditState.Size_Modify else camera.wall_update(camera.wall_view)
	tab_select.enabled() if current_state == EditState.Object_Select else tab_select.disabled()
	
	mouse.enabled() if current_state == EditState.Edit_Objects else mouse.disabled()
	
	resize_prompt.visible = true if current_state != EditState.Size_Modify else false
	place_prompt.visible = true if current_state != EditState.Object_Select else false
	tab_select_prompt.visible = true if current_state == EditState.Object_Select else false

#this will tell us if the wall has been changed by the tab_select and we will send it from here to where its needed
signal is_wall_change(state: bool)
func _on_tab_select_is_wall_change(state: bool) -> void:
	is_wall_change.emit(state)

func assign_tab_select_inventories():
	tab_select.assign_inventory_scripts(floor_furniture_inventory, placeable_inventory,wall_furniture_inventory,wallpaper_inventory,flooring_inventory)
