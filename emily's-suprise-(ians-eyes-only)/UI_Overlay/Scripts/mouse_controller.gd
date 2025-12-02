extends Marker2D
@export var SPEED = 300.0        # Normal movement speed
@export var INCREMENT = 5.0      # Kiss-in mode step size

var kiss_in_mode := false


func enabled():
	visible = true


func disabled():
	visible = false
	kiss_in_mode = false


func _process(delta: float) -> void:
	if not visible:
		return

	# Toggle Kiss-In Mode
	if Input.is_action_just_pressed("kiss_in_mode"):
		kiss_in_mode = !kiss_in_mode

	# Handle movement depending on mode
	if kiss_in_mode:
		_process_kiss_in_mode()
	else:
		_process_normal_mode(delta)


func _process_normal_mode(delta: float) -> void:
	var input_dir := Input.get_vector("Left", "Right", "Up", "Down")
	if input_dir != Vector2.ZERO:
		position += input_dir * SPEED * delta
		_clamp_to_screen()


func _process_kiss_in_mode() -> void:
	if Input.is_action_just_pressed("Left"):
		position.x -= INCREMENT
	if Input.is_action_just_pressed("Right"):
		position.x += INCREMENT
	if Input.is_action_just_pressed("Up"):
		position.y -= INCREMENT
	if Input.is_action_just_pressed("Down"):
		position.y += INCREMENT

	_clamp_to_screen()


func _clamp_to_screen() -> void:
	position.x = clamp(position.x, 0, get_viewport().size.x)
	position.y = clamp(position.y, 0, get_viewport().size.y)
			
