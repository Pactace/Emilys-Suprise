extends Node3D

var camera: Camera3D
var previous_cam_z = Vector3(0, 0, 1)
var standard_material: StandardMaterial3D
@onready var mesh = $Mesh
@onready var transition_screen = $"../TransitionScreen"

@export_file("*.tscn") var connected_door: String

func _ready() -> void:
	camera = get_viewport().get_camera_3d()
	mesh.material_override = mesh.get_surface_override_material(0).duplicate()
	standard_material = mesh.material_override

func _process(delta: float) -> void:
	if camera && camera.basis.z != previous_cam_z:
		var dot_product = get_global_transform().basis.x.dot(camera.basis.z)
		if dot_product < .4:
			standard_material.albedo_color.a = 1
		else: 
			standard_material.albedo_color.a = 0.2
		previous_cam_z = camera.basis.z
		
func enter_portal():
	transition_screen.exit = true
