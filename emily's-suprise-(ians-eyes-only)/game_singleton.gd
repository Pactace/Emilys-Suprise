extends Node

var current_time: Dictionary
const UPDATE_INTERVAL := 60.0  # check once per minute is plenty
var current_song: String = ""
var song_changed := false
var lines = []
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
	_update_dialogue_lines()

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
		
func _update_dialogue_lines() -> void:
	var day: int = int(current_time.day)

	if day == 8:
		lines = [
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
	if day == 9:
		lines = [
			"Hey honey!",
			"I hope you enjoyed the little demo yesterday!",
			"I know we were pretty busy but I wanted you to have some fun!",
			"Anyways today is gonna be pretty chill because its Sunday",
			"I think theres just a new wallpaper in the back if you want it",
			"Besides that just enjoy decorating the entryway",
			"They really want it to be a welcoming space for anyone to come in and feel at home",
			"Just like how you make me feel at home <3",
			"Anyways I got to go",
			"I love you darling! Youre my favorite person!"
		]
	if day == 10:
		lines = [
			"Hey darling! I hope you had fun yesterday decorating the entryway!",
			"I was talking to the owner today and he says that he's going to unlock the office.",
			"Thats the first door on your right as you walk in",
			"He shares it with his lovely wife",
			"Shes more of the creative type she needs drawing materials for her work",
			"The husband needs a gaming desk for his work and usually prefers a whiteboard to organize his thoughts",
			"They both love their plants so make sure to add plenty of those",
			"Anyways I got to go, I love you madly tho!",
			"Especially those beautiful hazel eyes you have",
			"Uysh so entrancing",
			"Anyways have a good day love!"
		]
	if day == 11:
		lines = [
			"Good Morning Princess! How was the office? do you feel like an official buisnesswoman placing all those copiers?",
			"Hehe.",
			"Anyways, I hope you are ready for another full day today!",
			"jk its just another wallpaper hehe",
			"but maybe you can do something something extra with it.",
			"You know what I love about you most darling",
			"Your sweet smile",
			"You have literally the prettiest smile I have ever seen",
			"Those and your eyes are a deadly combination",
			"Poor me haha, subjected to such torment!",
			"I hope you are smiling now",
			"Have a good day darling"
		]
	if day == 12:
		lines = [
			"Hello my gorgeous girl!",
			"I hope you've had a wonderful day thus far!",
			"Today you get the best job in the house!",
			"Da stinky toilettttt!!!",
			"I can tell you are so excited :3",
			"In all seriousness the owners need you to make the entryway bathroom",
			"its the second door on your right when you get in the house",
			"it should be a pinch",
			"anyways I hope you have fun!",
			"I also hope you laughed at dat stinky toilet joke",
			"I absolutely adore your laugh",
			"Anyways sweetcheeks I got to bounce!",
			"I love you tons!"
		]
	if day == 13:
		lines = [
			"Morning sunshine! Another big decorating day ahead!",
			"The client said they loved your last setup.",
			"Keep up that energy today!"
		]
	if day == 14:
		lines = [
			"Morning sunshine! Another big decorating day ahead!",
			"The client said they loved your last setup.",
			"Keep up that energy today!"
		]
	if day == 15:
		lines = [
			"Morning sunshine! Another big decorating day ahead!",
			"The client said they loved your last setup.",
			"Keep up that energy today!"
		]
	if day == 16:
		lines = [
			"Morning sunshine! Another big decorating day ahead!",
			"The client said they loved your last setup.",
			"Keep up that energy today!"
		]
	if day == 17:
		lines = [
			"Morning sunshine! Another big decorating day ahead!",
			"The client said they loved your last setup.",
			"Keep up that energy today!"
		]
	if day == 18:
		lines = [
			"Morning sunshine! Another big decorating day ahead!",
			"The client said they loved your last setup.",
			"Keep up that energy today!"
		]
	if day == 19:
		lines = [
			"Morning sunshine! Another big decorating day ahead!",
			"The client said they loved your last setup.",
			"Keep up that energy today!"
		]
	if day == 20:
		lines = [
			"Morning sunshine! Another big decorating day ahead!",
			"The client said they loved your last setup.",
			"Keep up that energy today!"
		]
	if day == 21:
		lines = [
			"Morning sunshine! Another big decorating day ahead!",
			"The client said they loved your last setup.",
			"Keep up that energy today!"
	]
	if day == 22:
		lines = [
			"Morning sunshine! Another big decorating day ahead!",
			"The client said they loved your last setup.",
			"Keep up that energy today!"
	]
	if day == 23:
		lines = [
			"Morning sunshine! Another big decorating day ahead!",
			"The client said they loved your last setup.",
			"Keep up that energy today!"
	]
	if day == 24:
		lines = [
			"Morning sunshine! Another big decorating day ahead!",
			"The client said they loved your last setup.",
			"Keep up that energy today!"
	]
	if day == 25:
		lines = [
			"Morning sunshine! Another big decorating day ahead!",
			"The client said they loved your last setup.",
			"Keep up that energy today!"
	]
	if day == 26:
		lines = [
			"Morning sunshine! Another big decorating day ahead!",
			"The client said they loved your last setup.",
			"Keep up that energy today!"
	]
	if day == 27:
		lines = [
			"Morning sunshine! Another big decorating day ahead!",
			"The client said they loved your last setup.",
			"Keep up that energy today!"
	]
	if day == 28:
		lines = [
			"Morning sunshine! Another big decorating day ahead!",
			"The client said they loved your last setup.",
			"Keep up that energy today!"
	]
	if day == 29:
		lines = [
			"Morning sunshine! Another big decorating day ahead!",
			"The client said they loved your last setup.",
			"Keep up that energy today!"
	]
	if day == 30:
		lines = [
			"Morning sunshine! Another big decorating day ahead!",
			"The client said they loved your last setup.",
			"Keep up that energy today!"
	]
	if day == 1:
		lines = [
			"Morning sunshine! Another big decorating day ahead!",
			"The client said they loved your last setup.",
			"Keep up that energy today!"
	]
	if day == 2:
		lines = [
			"Morning sunshine! Another big decorating day ahead!",
			"The client said they loved your last setup.",
			"Keep up that energy today!"
	]
	if day == 3:
		lines = [
			"Morning sunshine! Another big decorating day ahead!",
			"The client said they loved your last setup.",
			"Keep up that energy today!"
	]
	if day == 4:
		lines = [
			"Morning sunshine! Another big decorating day ahead!",
			"The client said they loved your last setup.",
			"Keep up that energy today!"
	]
	if day == 5:
		lines = [
			"Morning sunshine! Another big decorating day ahead!",
			"The client said they loved your last setup.",
			"Keep up that energy today!"
	]
