extends Pawn


onready var InputHandler = $InputHandler/Joypads
onready var Alex = $Alex
onready var GroundRay = $GroundRay

export var mode_move := 3

var _debug := false
var _is_on_ground := false
var _timer := 0.0

const GRACE_PERIOD := 0.2 # extra time on ground to allow jumping
const MOVE_ACCELERATION := Vector2(200, 1000) # acceleration through move input
const MAX_SPEED := Vector2(500, 2000) # max move speed

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

		# TODO: correctly clamp move acceleration
		_speed = clamp(_speed, -MAX_SPEED.x, MAX_SPEED.x)

		_velocity += dir * _speed
		if _debug: print("velocity: ", _velocity, " for dir: ", dir, " and speed: ", _speed)

		# only apply gravity in the air
		if not _is_on_ground:
			apply_gravity(delta)
			if _debug: print("velocity: ", _velocity, " after adding gravity: ", (Constants.GRAVITY * mass * delta))
		else:
			if jump:
				initial_jump()
			# TODO FIXME: should be handled by drag
			#else:
			#	_velocity.y = 0

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

	# FIXME: cannot clamp total velocity because that would nullify applied_force
	#_velocity.x = clamp(_velocity.x, -MAX_SPEED.x, MAX_SPEED.x)

	_velocity = move_and_slide(_velocity)
	#print("final velocity after slide: ", _velocity)

	# get collision normal to check if is on ground
	var amount = 0
	var normal = Vector2.ZERO
	var collider = null

	var debug_col = false

	var use_average = true
	# average all collected collision normals
	# collider could be different, but since only ground_velocity is used
	# this should be no problem
	if use_average:
		if get_slide_count() > 0:
			var count = get_slide_count()
			if debug_col: print("sliding collision count: ", count)
			for i in count:
				var collision = get_slide_collision(i)
				if debug_col: print("	", i, ". normal: ", collision.normal)
				amount += 1
				normal += collision.normal
				if collider != collision.collider:
					collider = collision.collider
					if debug_col: print("setting new collider: ", collider.name)

		# use a safety raycast to determine on floor
		#$GroundRay.force_raycast_update()
		if GroundRay.is_colliding():
			if debug_col: print("	raycast normal: ", GroundRay.get_collision_normal())
			if use_average:
				amount += 1
				normal += GroundRay.get_collision_normal()
				if collider != GroundRay.get_collider():
					collider = GroundRay.get_collider()
			else:
				normal = GroundRay.get_collision_normal()
				collider = GroundRay.get_collider()

		normal = normal / max(amount, 1)
		if debug_col: print("==== average normal: ", normal)

	# only rely on raycast
	else:
		if GroundRay.is_colliding():
			normal = GroundRay.get_collision_normal()
			if debug_col: print("	raycast normal: ", normal)
			collider = GroundRay.get_collider()

	if normal.y < -0.85:

		if not _is_on_ground:
			print("on ground")
			_timer = 0.0
			_is_on_ground = true
	
	# otherwise player is not necessarily in the air
	# but forbidden to jump -> still set rotation
	elif _is_on_ground:
		_timer += delta
		if _timer > GRACE_PERIOD:
			print("lost ground for timer: ", _timer)
			_is_on_ground = false

	# TODO FIXME: lerping rotation works better than setting instantly,
	#			  -> maybe adding a timer to fully remove flickering?
	var rotator = $CollisionShape2D
	rotator.rotation = lerp(rotator.rotation, asin(normal.dot(Vector2.RIGHT)), 0.1)

	set_floor_velocity(collider) # set to Vector2.ZERO if null


func initial_jump() -> void:
	print("jump")
	_is_on_ground = false
	_velocity.y -= MOVE_ACCELERATION.y

func set_floor_velocity(collider:Object = null) -> void:
	if collider and collider.has_method("get_ground_velocity"):
		var vel = collider.get_ground_velocity()
		if vel != ground_velocity:
			ground_velocity = vel
			_velocity = ground_velocity
	else:
		ground_velocity = Vector2.ZERO
