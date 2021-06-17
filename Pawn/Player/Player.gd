extends Pawn


onready var InputHandler = $Joypads

export var variant := 3

var _debug := false


func _physics_process(delta: float) -> void:

	# speed is acceleration * delta
	# velocity is dir * speed

	############	 	variant 1		 ############
	#################################################
	# use vec2 * vec2 to combine move and jump
	# 	- would always add jump -> add 0 in air
	# 	- add modifier for move acceleration.y and gravity
	if variant == 1:
		
		var dir := Vector2(
			Input.get_action_strength("move_right") - Input.get_action_strength("move_left"),
			-1.0 if Input.is_action_just_pressed("jump") and is_on_floor() else 0.0
		)

		_velocity += dir * Constants.MOVE_ACCELERATION * Vector2(1, 50)
		if _debug: print("velocity: ", _velocity, " for dir: ", dir)
		
		# apply forces like gravity
		apply_gravity(delta)
		if _debug: print("velocity: ", _velocity, " after adding gravity: ", (Constants.GRAVITY * _mass * delta))

		# adapt to velocity from ground
		if is_on_floor():
			_velocity.x = lerp(_velocity.x, ground_velocity.x, Constants.MOVE_DRAG)

	############	 	variant 2		 ############
	#################################################
	# its something, that doesn't feel shit :D
	elif variant == 2:
		# TODO: get from InputHandler
		var dir := Vector2(
			Input.get_action_strength("move_right") - Input.get_action_strength("move_left"),
			-Constants.MOVE_ACCELERATION.y if Input.is_action_just_pressed("jump") and is_on_floor() else 1.0
		)

		_velocity += dir * Constants.MOVE_ACCELERATION.x
		if _debug: print("velocity: ", _velocity, " for dir: ", dir)
		
		# apply forces like gravity
		apply_gravity(delta)
		if _debug: print("velocity: ", _velocity, " after adding gravity: ", (Constants.GRAVITY * _mass * delta))

		# adapt to velocity from ground
		_velocity.x = lerp(_velocity.x, ground_velocity.x, Constants.MOVE_DRAG)
	
	############	 	variant 3		 ############
	#################################################
	# handle seperate for move and jump/gravity
	# 	- implement using speed, acc and velocity
	# 	- seperate handling for x and y
	# 	- add modifier for move acceleration.y and gravity
	elif variant == 3:
		# TODO: get from InputHandler
		var dir := Vector2(
			Input.get_action_strength("move_right") - Input.get_action_strength("move_left"),
			0.0
		)

		if dir.x != 0:
			_speed += Constants.MOVE_ACCELERATION.x * delta
		else:
			_speed = 0

		_velocity += dir * _speed
		if _debug: print("velocity: ", _velocity, " for dir: ", dir, " and speed: ", _speed)

		# only apply gravity in the air
		if not is_on_floor():
			apply_gravity(delta)
			if _debug: print("velocity: ", _velocity, " after adding gravity: ", (Constants.GRAVITY * _mass * delta))
		else:
			if Input.is_action_just_pressed("jump"):
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
