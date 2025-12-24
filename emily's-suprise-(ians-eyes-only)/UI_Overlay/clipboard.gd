extends Control

@onready var clipboard_icon = $"../ClipboardIcon"
var enabled = true

func _ready() -> void:
	var room_name = get_tree().current_scene.room_name
	if(room_name == "Entryway"):
		get_child(1).text = "This is the first place the\nfather see's when arrivng\nafter a long day of work,\nthe kids after a long day\nof school. and visitors \nafter a long journey \n"
		get_child(3).text = "Make a place people\ncan feel at home as they\nenter, whether they live\nhere or not"

	elif(room_name == "Office"):
		get_child(1).text = "The mother and father\nboth work from home\nshe needs art tools\nfor her creative work\nthe father needs a gaming\ncomputer and whiteboard\n"
		get_child(3).text = "Make a place where they\ncan feel calm as they work\nthrough stresses\nof life together"

	elif(room_name == "GuestBathroom"):
		get_child(1).text = "This is the place\nguests use the restroom\nit should be simple\nand compact"
		get_child(3).text = "Make sure they\nhave a place\nto poop :3"

	elif(room_name == "TripleThreat"):
		get_child(1).text = "This is the place\nthe family spends most\nof their time\ncooking, eating, and\nhanging out in the\n kitchen, dinning room and\nliving room"
		get_child(3).text = "Make sure the family\nhas a place\nto cook together,\neat together, pray, read\nand watch movies"

	elif(room_name == "Basement"):
		get_child(1).text = "This is the place\nthe kids call there own\nthey hang out\n with friends and\nplay here"
		get_child(3).text = "Make sure the kids\nhave a place\nto play and enjoy"

	elif(room_name == "KidsBathroom"):
		get_child(1).text = "This is the place\nthe kids use every\nday before school\nand before bed,\nit should be easy\nto keep clean and\nsimple to move in\n"
		get_child(3).text = "Make sure the kids\nhave a bright place\nto brush teeth,\nwash hands and get\nready each day"

	elif(room_name == "StairsideHallway"):
		get_child(1).text = "This is the space\nthat connects rooms\nand floors of the\nhome, everyone\nwalks through it\nmany times a day\nso keep it cozy\n"
		get_child(3).text = "Make a place that\nfeels warm as the\nfamily moves from\nroom to room and\nkeeps things calm"

	elif(room_name == "LibrarySideHallway"):
		get_child(1).text = "This is the space\nthat connects rooms\nand floors of the\nhome, everyone\nwalks through it\nmany times a day\nso keep it cozy\n"
		get_child(3).text = "Make a place that\nfeels warm as the\nfamily moves from\nroom to room and\nkeeps things calm"

	elif(room_name == "MasterBedroom"):
		get_child(1).text = "This is the place\nwhere the mother\nand father rest,\nread and talk at\nnight, it should be\na peaceful place\njust for them\n"
		get_child(3).text = "Make a place where\nthey can feel close\ntogether as they end each\nday and start the\nnext with peace"

	elif(room_name == "MasterBathroom"):
		get_child(1).text = "This is the place\nwhere the parents\nget ready each day,\nshower, unwind and\nhave time to relax,\nit should feel clean\nand refreshing\n"
		get_child(3).text = "Make a calm place\nfor them to breathe, slow\ndown and feel renewed before \nthey face another day\n"

	elif(room_name == "KidsBedroom3"):
		get_child(1).text = "This is the place\nfor the oldest kid,\na 12 year old girl\nwho loves music,\nsoft lights and the\ncolor pink, this is\nher calm safe space\n"
		get_child(3).text = "Make sure she has\na cozy place where\nshe can listen to\nsongs, relax, read\nand feel inspired"

	elif(room_name == "KidsBedroom2"):
		get_child(1).text = "This is the room\nfor the twin boys\nage eight, one loves\nart and drawing,\nthe other loves his\nbaseball gear, and\nboth love video games\n"
		get_child(3).text = "Make a fun place\nwhere they can play,\ncreate, imagine,\nshare games, and\ngrow together"

	elif(room_name == "KidsBedroom1"):
		get_child(1).text = "This is the room\nfor the baby girl,\nsmall, sweet and\nfull of laughter,\nshe loves all her\nsoft plushies and\ncozy little things"
		get_child(3).text = "Make sure she feels\nwarm here,\nsurrounded by soft\ntoys, colors and a\ncomfy space"

	elif(room_name == "Terrace"):
		get_child(1).text = "This is the place\nwhere the family\nenjoys the fresh\nair, warm sun, and\ntime outside\ntogether on calm\ndays and nights\n"
		get_child(3).text = "Make a place where\npeace and nature\nmix, where they can\nsit, talk, relax,\nand enjoy views"

	elif(room_name == "BasementBathroom"):
		get_child(1).text = "This is the place\nused when hanging\nout downstairs,\nit should be handy,\nclean and simple\nfor family and\nfriends visiting\n"
		get_child(3).text = "Make sure guests\nand kids have a\nquick, comfy place\nto wash up during\nbasement fun"

	elif(room_name == "Library"):
		get_child(1).text = "A quiet room\nfor study and\nrest. The dad\nkeeps his cool\nmartial arts\nitems here."
		get_child(3).text = "Keep this spot\nsimple, tidy,\nand calm so all\ncan read and\nrelax easily."
	
	elif(room_name == "SittingRoom"):
		get_child(1).text = "The tower base\nwhere guests sit,\nfamily studies,\nand the daughter\nplays piano\nfor everyone."
		get_child(3).text = "Make sure it’s\nwarm, clean, and\nready so friends\nfeel welcome\nwhen visiting."
	
	elif(room_name == "TowerTop"):
		get_child(1).text = "A hideaway for\nkids and parents.\nThey come here on\nstormy nights to\nhear rain and\nplay games."
		get_child(3).text = "Keep it cozy so\nfamily can rest,\nplay, and watch\nstorms together\nin comfort."
	elif(room_name == "Mudroom"):
		get_child(1).text = "Put washer, do not put toilet unless you want stinkkkyyyy clothes"
		get_child(3).text = "I love youuuu hehehe"
		
func _process(delta: float) -> void:
	if get_parent().get_parent().current_state == get_parent().get_parent().PlayerState.Moving && enabled == false:
		print(enabled)
		if clipboard_icon.visible:
			clipboard_icon.visible = false
			visible = true  
		else:
			clipboard_icon.visible = true
			visible = false
		enabled = true
	elif enabled == true && get_parent().get_parent().current_state == get_parent().get_parent().PlayerState.Editing:
		enabled = false
		clipboard_icon.visible = false
		visible = false  


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("Toggle Colors & Spacing") && enabled == true:
		if clipboard_icon.visible:
			clipboard_icon.visible = false
			visible = true  
		else:
			clipboard_icon.visible = true
			visible = false  
