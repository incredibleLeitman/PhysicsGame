extends Pawn


onready var InputHandler = $InputHandler/Joypads
onready var Alex = $Alex
onready var GroundRay = $CollisionShape2D/GroundRay

export var mode_move := 3

var _debug := false
var _is_on_ground := false

const MOVE_ACCELERATION := Vector2(200, 1000)
const MAX_SPEED := Vector2(500, 2000)

func _process(delta: float) -> void:

	if abs(_velocity.x) > 0:
		Alex.flip_h = sign(_velocity.x) >= 0

func _physics_process(delta: float) -> void:

	# speed is acceleration * delta
	# velocity is dir * speed

	# get move dir from InputHandler
	var dir = InputHandler.get_move_dir()
	var jump = InputHandler.is_jumping()
	#if Input.is_key_pressed(KEY_M):
	if Input.is_action_just_pressed("change_mode_move"):
		mode_move = (mode_move + 1) % 5
		print("mode move changed: ", mode_move)
	
	############	 	mode_move 1		 ############
	#################################################
	# use vec2 * vec2 to combine move and jump
	# 	- would always add jump -> add 0 in air
	# 	- add modifier for move acceleration.y and gravity
	if mode_move == 1:

		dir.y = -1.0 if jump and _is_on_ground else 0.0

		_velocity += dir * MOVE_ACCELERATION
		if _debug: print("velocity: ", _velocity, " for dir: ", dir)
		
		# apply forces like gravity
		apply_gravity(delta)
		if _debug: print("velocity: ", _velocity, " after adding gravity: ", (Constants.GRAVITY * mass * delta))

		# adapt to velocity from ground
		_velocity.x = lerp(_velocity.x, ground_velocity.x, Constants.MOVE_DRAG)

	############	 	mode_move 2		 ############
	#################################################
	# its something, that doesn't feel shit :D
	elif mode_move == 2:

		dir.y = -MOVE_ACCELERATION.y if jump and _is_on_ground else 1.0

		_velocity += dir * MOVE_ACCELERATION.x
		if _debug: print("velocity: ", _velocity, " for dir: ", dir)
		
		# apply forces like gravity
		apply_gravity(delta)
		if _debug: print("velocity: ", _velocity, " after adding gravity: ", (Constants.GRAVITY * mass * delta))
	
	############	 	mode_move 3		 ############
	#################################################
	# handle seperate for move and jump/gravity
	# 	- implement using speed, acc and velocity
	# 	- seperate handling for x and y
	# 	- add modifier for move acceleration.y and gravity
	elif mode_move == 3:

		if dir.x != 0:
			_speed += MOVE_ACCELERATION.x * delta
		else:
			_speed = 0

		_velocity += dir * _speed
		if _debug: print("velocity: ", _velocity, " for dir: ", dir, " and speed: ", _speed)

		# only apply gravity in the air
		if not _is_on_ground:
			apply_gravity(delta)
			if _debug: print("velocity: ", _velocity, " after adding gravity: ", (Constants.GRAVITY * mass * delta))
		else:
			if jump:
				initial_jump()
			else:
				_velocity.y = 0

	############	 	mode_move 4		 ############
	#################################################
	# a fresh start
	elif mode_move == 4:

		_velocity += dir * MOVE_ACCELERATION.x * delta * mass

		if _is_on_ground:
			if jump:
				initial_jump()
		else:
			apply_gravity(delta)

		print("velocity: ", _velocity)

	apply_drag()

	# clamp to max speed
	_velocity.x = clamp(_velocity.x, -MAX_SPEED.x, MAX_SPEED.x)

	#print("final velocity: ", _velocity)
	_velocity = move_and_slide(_velocity)
	#print("final velocity after slide: ", _velocity)

	if get_slide_count() > 0:

		var collision = get_slide_collision(0)
		if collision.normal.y < -0.85 and not _is_on_ground:
			print("on ground")
			_is_on_ground = true

		$CollisionShape2D.rotation = -acos(collision.normal.dot(Vector2.UP))

		set_floor_velocity(collision.collider)

	#elif _is_on_ground:
	else:
		# use a safety raycast to determine on floor
		#$GroundRay.force_raycast_update()
		if not GroundRay.is_colliding():
			if _is_on_ground:
				print("lost ground")
			_is_on_ground = false
			$CollisionShape2D.rotation = 0
			ground_velocity = Vector2.ZERO
		else:
			set_floor_velocity(GroundRay.get_collider())

func initial_jump() -> void:
	print("jump")
	_is_on_ground = false
	_velocity.y -= MOVE_ACCELERATION.y

func set_floor_velocity(collider) -> void:
	if collider.has_method("get_ground_velocity"):
		var vel = collider.get_ground_velocity()
		if vel != ground_velocity:
			ground_velocity = vel
			_velocity = ground_velocity
	#elif not ground_velocity.is_equal_approx(Vector2.ZERO):
	#	ground_velocity = Vector2.ZERO
