extends Pawn


onready var Alex = $Alex
onready var GroundRay = $GroundRay
onready var InputHandler = $InputHandler/Joypads

export var mode_move := 2
export var mode_jump := 2

var _timer_ground := 0.0 # grace period timer for on_ground
var _jump_end := 0.0 # determine max jump time

# print debug values
var _debug := false
var _debug_jump := false
var _debug_ground := false

const GRACE_PERIOD := 0.2 # extra time on ground to allow jumping "coyote time"
#const MOVE_ACCELERATION := Vector2(200, 300) # acceleration through move input
const MOVE_ACCELERATION := Vector2(500, 300) # acceleration through move input
const MAX_SPEED := Vector2(500, 2000) # max move speed
const JUMP_DECAY := 0.4 # reducing part for jump functions
const JUMP_TIME := 50 # time in ms for how long adding additional jump force is allowed


func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("change_mode_move"):
		mode_move = (mode_move + 1) % 3
		print("mode move changed: ", mode_move)
	if Input.is_action_just_pressed("change_mode_jump"):
		mode_jump = (mode_jump + 1) % 3
		print("mode jump changed: ", mode_jump)


func _physics_process(delta: float) -> void:

	# Euler: displace then calculate velocity
	if mode_move == 0:

		_perform_move()
		_calculate_move()
		apply_gravity()
		apply_drag()

	# Improved Euler: calculate acceleration and displace
	elif mode_move == 1:

		var u = _velocity

		_calculate_move()
		apply_gravity()
		apply_drag()

		var v = _velocity
		var a = (v - u) * delta

		#_velocity = u + a * delta
		_velocity = u + delta * delta * a/2

		_perform_move()

		#_velocity = v

	# Euler-Cromer: calculate velocity then move
	elif mode_move == 2:

		_calculate_move()
		apply_gravity()
		apply_drag()
		_perform_move()


func _calculate_move() -> void:

	# get move dir from InputHandler
	var dir = InputHandler.get_move_dir()

	# accelerating by amount of input strength increasing speed until MAX_SPEED is reached
	#_speed = (abs(dir.x) * _speed) + (MOVE_ACCELERATION.x * abs(dir.x) * get_physics_process_delta_time())
	_speed = clamp((abs(dir.x) * _speed) + (MOVE_ACCELERATION.x * abs(dir.x) * get_physics_process_delta_time()), -MAX_SPEED.x, MAX_SPEED.x)

	if abs(_velocity.x) < MAX_SPEED.x:
		_velocity += dir * _speed
		#_velocity += dir * MOVE_ACCELERATION.x * abs(dir.x)

	if InputHandler.is_jumping():
		_jump()


func _jump() -> void:

	# no jump if not grounded
	if not _is_on_ground:
		return

	var cur_ms = OS.get_ticks_msec()

	if _jump_end == 0.0:
		if _debug_jump: print("\nmode: ", mode_jump, " jump start at: ", cur_ms)
		_jump_end = cur_ms + JUMP_TIME
	else:
		if cur_ms > _jump_end:
			if _debug_jump: print("end jump at: ", cur_ms)
			_jump_end = 0.0
			return

	var diff = cur_ms - (_jump_end - JUMP_TIME)
	var val = 0
	# jump variant 0 - linear damping
	if mode_jump == 0:
		val = (-diff * MOVE_ACCELERATION.y/JUMP_TIME + MOVE_ACCELERATION.y) * JUMP_DECAY

	# jump variant 1 - adding impuls with exponential of log function
	elif mode_jump == 1:
		val = exp(log(MOVE_ACCELERATION.y) - diff * 1/JUMP_DECAY)

	# jump variant 2 - adding impuls of cos wave
	elif mode_jump == 2:
		val = cos(diff * PI/2 / JUMP_TIME) * MOVE_ACCELERATION.y * JUMP_DECAY

	if _debug_jump: print("jump adding value: ", val, " for diff: ", diff)
	_velocity += val * Vector2.UP


func _perform_move() -> void:

	# actually move the pawn
	_velocity = move_and_slide(_velocity)

	# align sprite with movement direction
	if abs(_velocity.x) > 0:
		Alex.flip_h = sign(_velocity.x) >= 0

	_check_on_ground()


func _check_on_ground() -> void:
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
			amount += 1
			normal += GroundRay.get_collision_normal()
			if collider != GroundRay.get_collider():
				collider = GroundRay.get_collider()

		normal = normal / max(amount, 1)
		if debug_col: print("==== average normal: ", normal)

	# only rely on raycast
	else:
		if GroundRay.is_colliding():
			normal = GroundRay.get_collision_normal()
			if debug_col: print("	raycast normal: ", normal)
			collider = GroundRay.get_collider()

	# set player grounded if has a bottom collider
	# and collision normal is greater than 45 degrees
	if normal.y < -0.78:
		if not _is_on_ground:
			if _debug_ground: print("on ground @", OS.get_ticks_msec())
			_timer_ground = 0.0
			_is_on_ground = true
			_jump_end = 0.0
	# otherwise player is not necessarily in the air
	# but forbidden to jump -> still set rotation
	elif _is_on_ground:
		_timer_ground += get_physics_process_delta_time()
		if _timer_ground > GRACE_PERIOD:
			if _debug_ground: print("lost ground @", OS.get_ticks_msec())
			_is_on_ground = false

	_set_floor_velocity(collider) # set to Vector2.ZERO if null

	# TODO FIXME: lerping rotation works better than setting instantly,
	#			  -> maybe adding a timer to fully remove flickering?
	var rotator = $CollisionShape2D
	rotator.rotation = lerp(rotator.rotation, asin(normal.dot(Vector2.RIGHT)), 0.1)


func _set_floor_velocity(collider:Object = null) -> void:
	if collider and collider.has_method("get_ground_velocity"):
		var vel = collider.get_ground_velocity()
		if vel != ground_velocity:
			ground_velocity = vel
			#_velocity = ground_velocity # drag lerps to this velocity
	else:
		ground_velocity = Vector2.ZERO
