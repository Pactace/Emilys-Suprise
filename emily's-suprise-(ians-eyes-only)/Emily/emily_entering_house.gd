extends Node3D
@onready var anim_player: AnimationPlayer = $AnimationPlayer
@export var timer := 3.0
var elapsed = 0.0
var start_walking := false
var arrived := false

func _ready():
	anim_player.play_section("Action", 0, 1.12)
	anim_player.speed_scale = .7

func _on_emily_play_walking() -> void:
	anim_player.play("rigAction")
	anim_player.speed_scale = 2.0
	

func _process(delta: float) -> void:
	elapsed += delta
	if elapsed > timer:
		if !start_walking:
			_on_emily_play_walking()
			start_walking = true
		position.z -= 0.05
	if position.z <= -30.0 && !arrived:
		$AudioStreamPlayer3D.play(1)
		arrived = true
	if position.z <= -32:
		$"../TransitionScreen".exit = true
