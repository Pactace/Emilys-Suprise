extends AudioStreamPlayer3D

@onready var morning_song := preload("res://Levels/Components/8-10AM.mp3")
@onready var midmorning_song := preload("res://Levels/Components/10-12AM.mp3")
@onready var noon_song := preload("res://Levels/Components/12-2PM.mp3")
@onready var afternoon_song := preload("res://Levels/Components/2-4PM.mp3")
@onready var late_afternoon_song := preload("res://Levels/Components/4-6PM.mp3")
@onready var early_evening_song := preload("res://Levels/Components/6-8PM.mp3")
@onready var evening_song := preload("res://Levels/Components/8-10PM.mp3")
@onready var night_song := preload("res://Levels/Components/10PM-8AM.mp3")

var in_enter = true

@onready var tween := get_tree().create_tween()
var fade_duration := 1.0

func _ready() -> void:
	volume_db = 0.0
	_update_song()

func _process(_delta: float) -> void:
	if GameSingleton.song_changed:
		_update_song()

func _update_song() -> void:
	var new_stream: AudioStream
	match GameSingleton.current_song:
		"res://Levels/Components/8-10AM.mp3":
			new_stream = morning_song
		"res://Levels/Components/10-12AM.mp3":
			new_stream = midmorning_song
		"res://Levels/Components/12-2PM.mp3":
			new_stream = noon_song
		"res://Levels/Components/2-4PM.mp3":
			new_stream = afternoon_song
		"res://Levels/Components/4-6PM.mp3":
			new_stream = late_afternoon_song
		"res://Levels/Components/6-8PM.mp3":
			new_stream = early_evening_song
		"res://Levels/Components/8-10PM.mp3":
			new_stream = evening_song
		"res://Levels/Components/10PM-8AM.mp3":
			new_stream = night_song
		_:
			return
	
	# Only fade if the song is different
	if stream != new_stream or in_enter:
		_fade_to_new_song(new_stream)
		in_enter = false
	
	GameSingleton.song_changed = false


func _fade_to_new_song(new_stream: AudioStream) -> void:
	# Kill any old tweens in progress
	if tween and tween.is_running():
		tween.kill()

	# Create a new tween for smooth transition
	tween = get_tree().create_tween()
	tween.tween_property(self, "volume_db", -40.0, fade_duration)
	tween.tween_callback(Callable(self, "_switch_song").bind(new_stream))
	tween.tween_property(self, "volume_db", 0.0, fade_duration)


func _switch_song(new_stream: AudioStream) -> void:
	stop()
	stream = new_stream
	play()
