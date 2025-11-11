extends Node3D

@export var next_scene: String
@onready var transition_screen = $"../../TransitionScreen"
@export var marker: Marker3D
@export var next_door: String
@export var unlocked_day: int

func enter_portal():
	GameSingleton.door_name = next_door
	transition_screen.exit = true
	transition_screen.enter = false
	transition_screen.next_scene = next_scene
