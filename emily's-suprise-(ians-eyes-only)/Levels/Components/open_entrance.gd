extends Node3D

@export var next_scene: String
@onready var transition_screen = $"../TransitionScreen"

func enter_portal():
	transition_screen.reveal_speed = 2.0
	transition_screen.exit = true
	transition_screen.next_scene = next_scene
