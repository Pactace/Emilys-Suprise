extends AudioStreamPlayer3D

var woosh = preload("res://Levels/Components/SoundEffects/whoosh-velocity-383019.mp3")
var ui_move = preload("res://Levels/Components/SoundEffects/mixkit-game-ball-tap-2073.wav")
var spawn_object = preload("res://Levels/Components/SoundEffects/sharp-pop-328170.mp3")
var select_object = preload("res://Levels/Components/SoundEffects/mixkit-arcade-game-jump-coin-216.wav")
var place_object = preload("res://Levels/Components/SoundEffects/pop-268648.mp3")
var rotate_object = preload("res://Levels/Components/SoundEffects/mixkit-revolver-chamber-spin-1674.wav")
var delete_object = preload("res://Levels/Components/SoundEffects/pop-423717.mp3")
var switch_ui = preload("res://Levels/Components/SoundEffects/select-button-ui-395763.mp3")

func play_rotate_room():
	stream = woosh
	volume_db = -20
	pitch_scale = 3.0
	play(0.1)
	
func play_ui_switch():
	stream = ui_move
	volume_db = -5.0
	pitch_scale = 1.0
	play()
	
func play_spawn_object():
	stream = spawn_object
	volume_db = -20.0
	pitch_scale = 1.0
	play()
	
func play_select_object():
	stream = select_object 
	volume_db = -20.0
	pitch_scale = 1.0
	play()
	
func play_place_object():
	stream = place_object 
	volume_db = -15.0
	pitch_scale = 1.0
	play()
	
func play_rotate_object():
	stream = rotate_object
	volume_db = -15
	pitch_scale = 1.0
	play()
	
func play_delete_object():
	stream = delete_object
	volume_db = -20
	pitch_scale = 1.0
	play()
	
func play_switch_ui():
	stream = switch_ui
	volume_db = -10
	pitch_scale = 1.0
	play()
	
func play_increase():
	stream = select_object 
	volume_db = -22.0
	pitch_scale = 1.0
	play()
	
func play_decrease():
	stream = place_object 
	volume_db = -17.0
	pitch_scale = 1.0
	play()
