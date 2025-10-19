extends AnimatedSprite2D

@export var start_delay: float = 3.0
@onready var start = $"../Start"
@onready var transition_screen = $"../TransitionScreen"
@onready var moving_van = $"../Moving van"
var exit = false

func _ready() -> void:
	visible = false
	await get_tree().create_timer(start_delay).timeout
	visible = true
	play()

func _process(delta: float) -> void:
	if !exit:
		if frame > 40:
			stop()
			frame = 40
			start.visible = true
	else:
		if frame == 0:
			stop()
			visible = false

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("Accept") && start.visible == true:
		visible = false
		moving_van.speed_away()
		start.visible = false
