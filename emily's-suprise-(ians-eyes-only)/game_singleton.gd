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
	print(Time.get_unix_time_from_system())
	if (current_time.year == 2025 && current_time.month == 12 && current_time.day == 12 && current_time.hour == 18 && current_time.minute == 30):
		get_tree().change_scene_to_file("res://Start and Pause Menus/ProposalScene.tscn")
		
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
	var month: int =  int(current_time.month)
	var year: int = int(current_time.year)

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
			"Hello my dear :3",
			"I loved spending yesterday with you, my darling.",
			"I’m definitely missing you a ton right now.",
			"Anyways, we have a bit of an update on how things are going to work now.",
			"I’ve talked to the owners of the house, and they’ve said they will be giving you pieces of paper for each room you unlock to help guide you in their creation.",
			"There also have been minor improvements to the game that I hope you enjoy, my dear.",
			"I do it all for you.",
			"Never fear though, with the new changes I will still be calling you every day to tell you all the wonderful things I love about you.",
			"Anyways, my dear, there should be a few new features for you to try out today and something big for tomorrow.",
			"Anyways, I love you madly and I hope you have a good day!"
		]

	elif day == 14:
		lines = [
			"Hello again, sweetness.",
			"I hope you’re having a great day off today!",
			"Today’s a big day!",
			"Today you unlock the TRIPLETHREAT.",
			"At least that’s what I call it — you’ll see why in just a moment.",
			"It’s straight on as you enter the building.",
			"Anyways, today I wanted to talk about your brilliant wit.",
			"You know you’re the only girl that’s made me giggle and cackle so consistently with your wonderful jokes and your silliness?",
			"You’re like the funniest person in the world, I guess :3",
			"Anyways, I love you tons, my dear. Have a great day!"
		]

	elif day == 15:
		lines = [
			"It’s SATURDAYYYYY!",
			"You know what that means.",
			"COUSIN GAME NIGHHHHHT!!!",
			"Very exciting stuff.",
			"That’s one of my favorite parts about you, you know?",
			"I love how close you are with your family.",
			"I love how they love you and you love them.",
			"I want a family like that with you, my dear.",
			"Anyways, I can’t wait to see you today!",
			"I love you!"
		]

	elif day == 16:
		lines = [
			"Hello my beautiful gorgeous woman!",
			"I hope you’ve had a good Sunday so far!",
			"Today is a pretty chill day again — just a new wallpaper.",
			"Do you know what one of my favorite parts about you is?",
			"Your spirituality!",
			"I love how we read scriptures together.",
			"I love our trips to the temple.",
			"(Especially seeing you so beautiful across the altar.)",
			"I love our prayers.",
			"And our spiritual discussions.",
			"I love holding your hand in church :3",
			"Anyways, I can’t wait to see you today, my darling woman!",
			"Have a good Sunday!"
		]

	if day == 17:
		lines = [
			"Hello Darling! I hope you are having a good day today!",
			"You know something that is interesting",
			"Recently I have been thinking about that one hang out we had",
			"The one where you just hung out with me while I studied for my precalc test",
			"We got food and just chilled while listening to music",
			"It was snowing outside",
			"That was almost 3 years ago",
			"Absolutely insane",
			"But I enjoyed that moment",
			"As I enjoy every moment with you now dearest",
			"Have a good day my love!",
			"I love you!"
		]
	if day == 18:
		lines = [
			"Morning sweetcheeks!",
			"I hope you are having a good day!",
			"I'm missing you like crazy most definetly",
			"I can't believe I have to wait until friday",
			"Anyways I want to tell you one of the things I love most about you",
			"Your wonderful patience",
			"I love how calm you are, and reasonable",
			"You are such a blessing in my life",
			"I feel like you are just so easy to talk to",
			"Anyways my love I think door by the kitchen should be open today",
			"You should go check it out",
			"I love you so much",
			"And I am so grateful for you!"
		]
	if day == 19:
		lines = [
			"Heyyyyy baby!",
			"Hope you had fun decortating the downstairs for the owner's kids yesterday",
			"I am sure they are goingt to love it as their own little space",
			"Anyways my love I just wanted to recite a little poem for you today",
			"I have a ray of sunshine",
			"To brighten up my cloudy days",
			"She brings me lots of smiles",
			"with her woundrous rays",
			"She is my own sweet woman",
			"The one I call my own",
			"With this dear sweet woman",
			"I want to build my home",
			"May my love be happy",
			"As happy my love makes me",
			"So hand in hand we'll journey on",
			"In love's warm light eternally.",
			"-Truly yours,",
			"-Ian",
			"I love you darling"
		]
	if day == 20:
		lines = [
			"Hello my sweet woman!",
			"I hope today is as beautiful as you are!",
			"Today you get another wonderful stinkyyyyyyy bathroom to decorate",
			"I hope your ready! :3",
			"Anyways my love I have a rather 'personal' complement today",
			"So if your showing this to a family member or whatever, best not show them this part",
			"They gone?",
			"Well then today I wanted to tell you how much I love those beautiful hips of yours",
			"I love how they just fit in my hand when I pull you close",
			"I love how you move them",
			"You are so unbelievably sexy and your hips are so unbelievably wonderful",
			"Anyways I hope you liked that spicier comment ;3",
			"Have a great day"
		]
	if day == 21:
		lines = [
			"Helloooo gorgeous!",
			"Hope you have been having a great day!",
			"Remember that time when we first hung out after your mission?",
			"Goofing off in the MOA",
			"You dying everytime it was your turn when we played Super Mario World",
			"Getting dinner and laughing",
			"Talking about the type of people wanted in our future relationships",
			"Realizing we were those people...",
			"Im glad I took a break from my drinking to hang out with you",
			"You ended up being my dream woman",
			"Have a good day my love"
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
			"HAHAHA just kidding Im back and better than ever my darling",
			"I hope you are ready for a full day today!",
			"I am definetly going to miss you this week :(",
			"But Ive left lots of things for you to play with while your away",
			"I hope you have a great week with your family I cant wait to see you soon :3",
			"I love you madly!",
			"Besitos amor <3"
	]
	if day == 26:
		lines = [
			"Heyyyy my darling gorgeous woman!",
			"I hope you had lots of fun yesterday",
			"You have lots to play today!",
			"Before you get to it though I just wanted to tell you how much I love you",
			"You make me feel at home my darling,",
			"The hours fly by when we are together I blink and its been 9 hours",
			"I dont know what we are going to do when we get married",
			"Years fly by like minutes with you my dear",
			"I love you madly! I cant wait to see you saturday!"
	]
	if day == 27:
		lines = [
			"Heyyyyy babyyy, todays gonna be another message like last week so be careful o_0",
			"You alone?",
			"Good.",
			"I just wanted to say how much I love those beautiful lips of yours",
			"I just love kissing them its my favorite",
			"I love when we connect and just melt into each other",
			"I cant wait to give you some smooches when you get back",
			"I love you darling!",
			"Have a great day! ;3"
	]
	if day == 28:
		lines = [
			"Good morning my loveeeeee",
			"I hope you slept well last night",
			"You know what I love darling?",
			"Cuddling my darling girl and falling asleep by her side",
			"You are such a good cuddler and you make me feel so comfortable",
			"and some times sleepy",
			"hehe",
			"I love you madly darling!"
	]
	if day == 29:
		lines = [
			"MY DARLINNNNGG!!!!!!!",
			"You will be home today!!!!!",
			"I hope you have been having fun this week",
			"Decorating all the stinkyyyyy bathrooms hehehehe",
			"I cant wait to see you today my love",
			"I hope you have fun decorating on the way back",
			"I love you my darling",
			"All of you",
			"All of the time <3",
			"Come home to me safe my little sugar wafer, ooie gooie bear",
			"hahahaha",
			"ciaocitos amor"
	]
	if day == 3 and month == 12 and year == 2025:
		lines = [
			"Morning sunshine! Another big decorating day ahead!",
			"HAHAHA just kidding Im back and better than ever my darling",
			"I finally figured all this junk",
			"I hope you had fun hanging out",
			"I definitley did",
			"I love you madly!",
			"Besitos amor <3"
		]
	if day == 4 and month == 12 and year == 2025:
		lines = [
			"Good morning my loveeeeee",
			"I hope you slept well last night",
			"You know what I love darling?",
			"Cuddling my darling girl and falling asleep by her side",
			"You are such a good cuddler and you make me feel so comfortable",
			"and some times sleepy",
			"hehe",
			"I love you madly darling!"
		]
	if day == 5 and month == 12 and year == 2025:
		lines = [
			"Good morning my loveeeeee",
			"I hope you slept well last night",
			"You know what I love darling?",
			"Cuddling my darling girl and falling asleep by her side",
			"You are such a good cuddler and you make me feel so comfortable",
			"and some times sleepy",
			"hehe",
			"I love you madly darling!"
		]
	if day == 6 and month == 12 and year == 2025:
		lines = [
			"Hey babyyyy!",
			"I hope you are having fun with the house,",
			"Dont worry if you have finished everything again there should be another update",
			"In another few days with some rooms I didnt get to add and some flooring to try out",
			"You know what I love about you my dear",
			"Your creatvity",
			"You are so creative",
			"Always making cool things with your hands",
			"Those little embroyderies",
			"The cute clay things",
			"I love those little presents you spend time making",
			"I love you madly!",
			"Besitos Amor <3"
		]
	if day == 7 and month == 12 and year == 2025:
		lines = [
			"Good morning my little carne asada fries burrito",
			"I hope you are relaxed this sunday",
			"I cant wait to see you today!",
			"With any luck the update should be ready",
			"Do you remember the beginning of our relationship",
			"When we were praying about getting together",
			"Well more like you",
			"I already knew",
			"Day 1 I remember praying to God after we hung out",
			"And I got the feeling that it would literally be the stupidest thing if we didnt get together",
			"I also thought Emily DeJesus had a nice ring to it.",
			"Anyways I'll see you later love!",
			"I love you madly!",
		]
	if day == 9 and month == 12 and year == 2025:
		lines = [
			"Good morning my dear sweet darling!",
			"I hope you are having a great relaxing day!",
			"I am so proud of you singing yesterday",
			"You sounded so good",
			"Well at least what I heard of you, drowned out in the background",
			"You are an amazing singer my love",
			"Thats one of the things I love about you!",
			"Anyways I hope you have a good day today!",
			"I love you madly"
		]
	if day == 10 and month == 12 and year == 2025:
		lines = [
			"HALLOOOOOOO",
			"MY DARLING WOMANNNNN",
			"I MISS YOU MADLYYYYYYY",
			"AGHHHHHHH",
			"hehehe",
			"Anyways",
			"I dont have any more rooms for you to decorate today so I would recommend you look for flooring that you like",
			"Obviously keep logging in for the next little while because I have lots of notes still to give you",
			"But I love you tons and I hope you have a great day!"
		]
	if day == 11 and month == 12 and year == 2025:
		lines = [
			"Hello my dear",
			"You know what I am thinking about today?",
			"I am thinking about that time we went to the mall to make little lego guys",
			"It was so fun just to chill and relax with you my dear",
			"And it was so fun to make you dad with da cheese headdddddd",
			"I love those little moments with you my darling",
			"I hope you know that :3",
			"I love you madly"
		]
	if day == 12 and month == 12 and year == 2025:
		lines = [
			"Hey love bug",
			"Today's going to be a bit different from other days",
			"I have decided I am sick of not seeing you this week",
			"So I was thinking  of adding some new wall mounted items to the game",
			"Anyways, I need you to come look at them so I have made a special cutscene for you today",
			"Where I'll pick you up and we can look at it together ok?",
			"I'll be picking you up around 6:30 today if that's okay dearest?",
			"So make sure your on the game at least ten minutes early with the game charged",
			"I can't wait to show you some cool stuff!",
			"I love youuuuu!"
		]
	
	
