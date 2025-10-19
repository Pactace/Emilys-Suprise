extends AudioStreamPlayer3D

var elapsed = 0.0
@export var timer = 1.0
var played := false

func _process(delta: float) -> void:
	elapsed += delta
	if elapsed >= timer && !played:
		play(0)
		played = true
	
