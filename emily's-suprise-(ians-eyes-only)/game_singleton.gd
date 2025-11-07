extends Node

var current_time: Dictionary
const UPDATE_INTERVAL := 60.0  # check once per minute is plenty
var current_song: String = ""
var song_changed := false

var door_name: String = "FrontDoor"

func set_door_name(new_name: String) -> void:
	door_name = new_name

func _ready() -> void:
	var timer := Timer.new()
	timer.wait_time = UPDATE_INTERVAL
	timer.timeout.connect(_on_update_timer_timeout)
	add_child(timer)
	timer.start()
	_on_update_timer_timeout()  # run immediately once at startup

func _on_update_timer_timeout() -> void:
	current_time = Time.get_datetime_dict_from_system()
	print(current_time)
	_update_music()

func _update_music() -> void:
	var hour := int(current_time.hour)
	var new_song := ""

	# Time ranges for your songs
	if hour >= 8 and hour < 10:
		new_song = "res://Levels/Components/8-10AM.mp3"
	elif hour >= 10 and hour < 12:
		new_song = "res://Levels/Components/10-12AM.mp3"
	elif hour >= 12 and hour < 14:
		new_song = "res://Levels/Components/12-2PM.mp3"
	elif hour >= 14 and hour < 16:
		new_song = "res://Levels/Components/2-4PM.mp3"
	elif hour >= 16 and hour < 18:
		new_song = "res://Levels/Components/4-6PM.mp3"
	elif hour >= 18 and hour < 20:
		new_song = "res://Levels/Components/6-8PM.mp3"
	elif hour >= 20 and hour < 22:
		new_song = "res://Levels/Components/8-10PM.mp3"
	else:
		# Covers 22:00–8:00
		new_song = "res://Levels/Components/10PM-8AM.mp3"

	# Only trigger a change when the song actually differs
	if new_song != current_song:
		current_song = new_song
		song_changed = true
		print("Now playing:", current_song)
