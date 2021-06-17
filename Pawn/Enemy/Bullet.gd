extends Pawn


export(Vector2) var initial_velocity := Vector2(2*MAX_SPEED.x, -500)
var max_lifetime := 7.0 # time before despawning in s ( = double the cannon shoot delay)
var cor := 0.5 # coefficient of restitution (bounciness)

var _alive := 0.0

# test disabling collision for a while after detection
var _ignored_collisions := {}

func _ready() -> void:
	_velocity = initial_velocity

func _physics_process(delta: float) -> void:

	var cur_ms = OS.get_ticks_msec()

	if not is_on_floor() and not _is_in_rest:
		#print("\n", cur_ms, " ", name, " apply gravity")
		apply_gravity(delta)

	# using move and collide to get collsion
	var collision = null
	#print("would move with vel: ", _velocity, " length: ", _velocity.length())
	collision = move_and_collide(_velocity * delta)

	# using move and slide and manually search for collisions
	#_velocity = move_and_slide(_velocity, Vector2.UP)
	#var slide_count = get_slide_count()
	#var collision = get_slide_collision(slide_count - 1) if slide_count else null
	if collision and collision.collider:

		if collision.collider is Enemy:
			# skipping basic enemy type
			pass
		#elif _ignored_collisions.has(collision.collider_id):
		#	# ignore recent collision for a while
		#	pass
		elif collision_handled:
			print("\n", cur_ms, " ", name, " is having collision handled -> pass")
			collision_handled = false
		else:
			print("\n", cur_ms, " collision from ", name, " with ", collision.collider.name, ", ", collision.collider_id)

			_ignored_collisions[collision.collider_id] = cur_ms

			# bounce off obstacles
			# material 		COR
			# zinc, nickel	0.15
			# glass			0.69
			# silicon		1.79

			if collision.collider is Pawn:

				var pawn := collision.collider as Pawn

				var m1 = _mass
				var m2 = pawn._mass
				var v1 = _velocity
				var v2 = pawn._velocity

				# handle other object bounce if its not a wall or RigidBody
				# could also store values before collision and aply after next tick
				# to that the collider use the same values before modifications
				print(pawn.name, " vel before bounce: ", v2, " length: ", v2.length())
				pawn.bounce(m2, m1, v2, v1, cor)
				print(pawn.name, " vel after bounce: ", pawn._velocity, " length: ", pawn._velocity.length())
				pawn.stop_at_rest()

				# mark as handled so that the object itself does not bounce
				pawn.collision_handled = true

				# handle own bounce
				print(name, " vel before bounce: ", v1, " length: ", v1.length())
				bounce(m1, m2, v1, v2, cor)
				print(name, " vel after bounce: ", _velocity, " length: ", _velocity.length())
				stop_at_rest()

			else:
				# use Godot integrated physics
				_velocity = _velocity.bounce(collision.normal) * 0.5
				#var remaining_vel = collision.remainder
				#_velocity = remaining_vel.bounce(collision.normal)

				print(name, " vel after bounce: ", _velocity, " length: ", _velocity.length())
				# this should stop the object from moving, which should stop colliding, which should stop endlessly adding gravity
				# should actually happen if drag is working correctly
				stop_at_rest()

				#_is_on_floor = collision.normal.y == -1
				#_is_on_floor = collision.normal.y < -0.9
				#print("setting is on floor: ", _is_on_floor, " GD is_on_floor: ", is_on_floor())

	#_velocity.x = lerp(_velocity.x, ground_velocity.x, Constants.MOVE_DRAG)
	#_velocity.y = lerp(_velocity.y, ground_velocity.y, Constants.MOVE_DRAG)

	# clearing ignored collision list after a delay
	for collider in _ignored_collisions:
		if cur_ms > _ignored_collisions[collider] + 300:
			_ignored_collisions.erase(collider)

	# destroy bullet after given lifetime
	_alive += delta
	if _alive > max_lifetime:
		queue_free()
