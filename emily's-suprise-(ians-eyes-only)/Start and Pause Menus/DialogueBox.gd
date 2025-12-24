extends TextureRect

@onready var dialogue = $RichTextLabel
@onready var moving_van = $"../Moving van"
@onready var transition_screen = $"../TransitionScreen"
@export var proposal := false

@export var pop_duration: float = 0.3
@export var pop_overshoot: float = 1.15
@export var start_delay: float = 3.0
@export var dialogue_typing_speed = 0.05  # lower = slower typing
@onready var button_prompt = $ButtonPrompt
var time_passed := 0.0
var fade_in_progress := 0.0
@export var blink_speed := 3.0

var dialogue_lines = [
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
	if !proposal:
		dialogue_lines = GameSingleton.lines
	else:
		dialogue_lines = [
			"Yooooo, it's me your favorite person!",
			"Its so wonderful to see you face to face after LITERALLY A MONTH.",
			"My goodness I'm a bad partner",
			"Hehe JK JK",
			"I guess you understand why it took me so long on monday to make this part of the game though",
			"Supposedly just 'adding other rooms'",
			"hehe",
			"Anyways before we head off to check out these wall mounted items I just wanted to tell you",
			"how much I love what you've done with the place",
			"Its been such a joy watching you decorate and having fun with the game I spent so much time on",
			"Whenever you'd show me during our calls or when I would come to visit it always", 
			"brightened up my day seeing you turn this house into a home",
			"It makes me think of our future in this house",
			"All the kidleys running around",
			"Me and you having fun working together",
			"Building something that will last",
			"There's no one I'd rather do it with my dear sweet emily",
			"Anyways we should probably get going, we have some important things to do today!",
			"I'll take your character here in the game",
			"But there should be someone waiting outside for you in real life",
			"Go check outside theres someone that should be out front",
			"I love you madly! See you soon"
		]
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
			if !proposal:
				moving_van.speed_away()
			else:
				transition_screen.exit = true

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
