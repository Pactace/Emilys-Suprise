extends TextureRect

@onready var dialogue = $RichTextLabel
@onready var moving_van = $"../Moving van"

@export var pop_duration: float = 0.3
@export var pop_overshoot: float = 1.15
@export var start_delay: float = 3.0
@export var dialogue_typing_speed = 0.05  # lower = slower typing
@onready var button_prompt = $ButtonPrompt
var time_passed := 0.0
var fade_in_progress := 0.0
@export var blink_speed := 3.0

var dialogue_lines = [
	"Yooooo, it's me your favorite person!",
	"Calling you while you're on the road.",
	"You're heading to your next project today, right?",
	"Crazy thing, the owner specifically asked for you to handle the interior for this project.",
	"I guess they just fell in love with your style. ;)",
	"They've got good taste I suppose.",
	"hehe",
	"Anyways, they say they want it done in about a month, so it might be a bit of a challenge.",
	"But you've got this. I know you'll do wonderfully, darling.",
	"Have fun! Tell me how it goes, okay?",
	"I love you!"
]

var elapsed := 0.0
var started := false
var pop_timer := 0.0
var base_scale := Vector2(1, 1)
var animating_in := false
var animating_out := false
var dialogue_index := 0
var typing := false
var dialogue_start := false
var type_timer := 0.0


func _ready():
	visible = false
	scale = Vector2.ZERO
	dialogue.visible = false
	dialogue.text = dialogue_lines[dialogue_index]
	dialogue.visible_characters = 0

func _process(delta):
	elapsed += delta

	# Start after delay
	if not started and elapsed >= start_delay:
		started = true
		visible = true
		animating_in = true
		pop_timer = 0.0
		dialogue.visible = false

	# Pop in animation
	if animating_in:
		pop_timer += delta
		var t = clamp(pop_timer / pop_duration, 0.0, 1.0)
		var overshoot_t = sin(t * PI * 0.5)
		var scale_val = lerp(0.0, pop_overshoot, overshoot_t)
		scale = Vector2(scale_val, scale_val)

		if t >= 1.0:
			scale = base_scale
			animating_in = false
			dialogue.visible = true
			typing = true
			dialogue_start = true

	# Typewriter effect
	if typing:
		type_timer += delta
		if type_timer >= dialogue_typing_speed:
			type_timer = 0.0
			if dialogue.visible_characters < dialogue_lines[dialogue_index].length():
				dialogue.visible_characters += 1
			else:
				typing = false
				button_prompt.visible = true

	# Pop out animation
	if animating_out:
		pop_timer += delta
		var t = clamp(pop_timer / pop_duration, 0.0, 1.0)
		var smooth_t = sin(t * PI * 0.5)
		var scale_val = lerp(1.0, 0.0, smooth_t)
		scale = Vector2(scale_val, scale_val)

		if t >= 1.0:
			visible = false
			animating_out = false
			moving_van.speed_away()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("Accept") and dialogue_start:
		# Skip typing if still typing
		if typing:
			dialogue.visible_characters = dialogue_lines[dialogue_index].length()
			typing = false
			button_prompt.visible = true
			return

		# Next line or end
		if dialogue_index < dialogue_lines.size() - 1:
			dialogue_index += 1
			dialogue.text = dialogue_lines[dialogue_index]
			dialogue.visible_characters = 0
			typing = true
			button_prompt.visible = false
		else:
			dialogue_start = false
			animating_out = true
			pop_timer = 0.0
