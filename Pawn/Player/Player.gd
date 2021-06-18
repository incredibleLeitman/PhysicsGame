extends Pawn


onready var InputHandler = $InputHandler/Joypads
onready var Alex = $Blob/Alex

export var mode_move := 3

var _debug := false


func _process(delta: float) -> void:

	if abs(_velocity.x) > 0:
		Alex.flip_h = sign(_velocity.x) >= 0

func _physics_process(delta: float) -> void:

	# speed is acceleration * delta
	# velocity is dir * speed

	# get move dir from InputHandler
	var dir = InputHandler.get_move_dir()
	var jump = InputHandler.is_jumping()
	
	############	 	mode_move 1		 ############
	#################################################
	# use vec2 * vec2 to combine move and jump
	# 	- would always add jump -> add 0 in air
	# 	- add modifier for move acceleration.y and gravity
	if mode_move == 1:

		dir.y = -1.0 if jump and is_on_floor() else 0.0

		_velocity += dir * Constants.MOVE_ACCELERATION * Vector2(1, 50)
		if _debug: print("velocity: ", _velocity, " for dir: ", dir)
		
		# apply forces like gravity
		apply_gravity(delta)
		if _debug: print("velocity: ", _velocity, " after adding gravity: ", (Constants.GRAVITY * mass * delta))

		# adapt to velocity from ground
		if is_on_floor():
			_velocity.x = lerp(_velocity.x, ground_velocity.x, Constants.MOVE_DRAG)

	############	 	mode_move 2		 ############
	#################################################
	# its something, that doesn't feel shit :D
	elif mode_move == 2:

		dir.y = -Constants.MOVE_ACCELERATION.y if jump and is_on_floor() else 1.0

		_velocity += dir * Constants.MOVE_ACCELERATION.x
		if _debug: print("velocity: ", _velocity, " for dir: ", dir)
		
		# apply forces like gravity
		apply_gravity(delta)
		if _debug: print("velocity: ", _velocity, " after adding gravity: ", (Constants.GRAVITY * mass * delta))

		# adapt to velocity from ground
		_velocity.x = lerp(_velocity.x, ground_velocity.x, Constants.MOVE_DRAG)
	
	############	 	mode_move 3		 ############
	#################################################
	# handle seperate for move and jump/gravity
	# 	- implement using speed, acc and velocity
	# 	- seperate handling for x and y
	# 	- add modifier for move acceleration.y and gravity
	elif mode_move == 3:

		if dir.x != 0:
			_speed += Constants.MOVE_ACCELERATION.x * delta
		else:
			_speed = 0

		_velocity += dir * _speed
		if _debug: print("velocity: ", _velocity, " for dir: ", dir, " and speed: ", _speed)

		# only apply gravity in the air
		if not is_on_floor():
			apply_gravity(delta)
			if _debug: print("velocity: ", _velocity, " after adding gravity: ", (Constants.GRAVITY * mass * delta))
		else:
			if jump:
				_velocity.y -= Constants.MOVE_ACCELERATION.y * 50
			else:
				_velocity.y = 0

		# adapt to velocity from ground
		_velocity.x = lerp(_velocity.x, ground_velocity.x, Constants.MOVE_DRAG)
		#_velocity.y = lerp(_velocity.y, ground_velocity.y, Constants.MOVE_DRAG * 0.1)

	# clamp to max speed
	_velocity.x = clamp(_velocity.x, -MAX_SPEED.x, MAX_SPEED.x)

	if _debug: print("final velocity: ", _velocity)
	#_velocity = move_and_slide(_velocity, Vector2.UP)
	move_and_slide(_velocity, Vector2.UP)
