extends Area3D

enum SectionState {Kitchen, DiningRoom, LivingRoom}
@export var current_section: SectionState
var camera: Camera3D

func _ready() -> void:
	camera = $"../Camera"

func _on_body_entered(body: Node3D) -> void:
	camera.set_center(position)
