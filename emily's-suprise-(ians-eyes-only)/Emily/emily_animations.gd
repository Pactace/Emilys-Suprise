extends Node3D
@onready var anim_player: AnimationPlayer = $AnimationPlayer

func _ready():
	anim_player.play_section("Action", 0, 1.12)
	anim_player.speed_scale = .7
	
func _on_emily_play_idle() -> void:
	anim_player.play_section("Action", 0, 1.12)
	anim_player.speed_scale = .7

func _on_emily_play_walking() -> void:
	anim_player.play("rigAction")
	anim_player.speed_scale = 1.7
