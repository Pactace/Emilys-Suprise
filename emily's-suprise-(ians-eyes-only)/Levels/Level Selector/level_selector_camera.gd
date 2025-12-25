extends Camera2D

# --- Lerp ---
@export var LERP_SPEED := 5.0  # bigger = faster

# --- State ---
var target_index: int = 0
var target_pos: Vector2

var scenes = [
	"res://Start and Pause Menus/EnteringTheHouse.tscn",
	"res://Levels/Level Scenes/First Apartment/EnteringTheApartment.tscn",
]

@export var targets = {}

func _ready():
	target_pos = get_node(targets[target_index]).position
	get_child(2).text = get_node(targets[target_index]).name
	
func _process(delta: float) -> void:
	# Smooth transitions
	position = position.lerp(target_pos, delta * LERP_SPEED)
	if abs(floor(position.x) - floor(target_pos.x)) < 50:
		get_child(1).visible = true
		get_child(2).visible = true
	else:
		get_child(1).visible = false
		get_child(2).visible = false
	

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("Right"):
		if targets.has(target_index + 1):
			target_index = target_index + 1
			target_pos = get_node(targets[target_index]).position
			get_child(2).text = get_node(targets[target_index]).name
	if event.is_action_pressed("Left"):
		if targets.has(target_index - 1):
			target_index = target_index -1 
			target_pos = get_node(targets[target_index]).position
			get_child(2).text = get_node(targets[target_index]).name
	if event.is_action_pressed("Accept"):
		$TransitionScreen.next_scene = scenes[target_index]
		$TransitionScreen.exit = true
