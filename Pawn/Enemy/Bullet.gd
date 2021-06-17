extends Pawn


export(Vector2) var initial_velocity := Vector2(2*MAX_SPEED.x, -500)
export var max_lifetime := 7.0 # time before despawning in s ( = double the cannon shoot delay)
var _alive := 0.0 # determine current lifetime
export var cor := 0.5 # coefficient of restitution (bounciness)

var _debug_out := false


func _ready() -> void:
	_velocity = initial_velocity

func _physics_process(delta: float) -> void:

	var cur_ms = OS.get_ticks_msec()

	if not is_on_floor() and not _is_in_rest:
		apply_gravity(delta)

	# using move and collide to get collsion
	var collision = null
	collision = move_and_collide(_velocity * delta)

	# using move and slide and manually search for collisions
	#_velocity = move_and_slide(_velocity, Vector2.UP)
	#var slide_count = get_slide_count()
	#var collision = get_slide_collision(slide_count - 1) if slide_count else null
	if collision and collision.collider:

		if collision.collider is Enemy:
			# skipping basic enemy type
			pass
		elif collision_handled:
			if _debug_out: print("\n", cur_ms, " ", name, " is having collision handled -> pass")
			collision_handled = false
		else:
			if _debug_out: print("\n", cur_ms, " collision from ", name, " with ", collision.collider.name, ", ", collision.collider_id)

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
				if _debug_out: print(pawn.name, " vel before bounce: ", v2, " length: ", v2.length())
				pawn.bounce(m2, m1, v2, v1, cor)
				if _debug_out: print(pawn.name, " vel after bounce: ", pawn._velocity, " length: ", pawn._velocity.length())
				pawn.stop_at_rest()

				# mark as handled so that the object itself does not bounce
				pawn.collision_handled = true

				# handle own bounce
				if _debug_out: print(name, " vel before bounce: ", v1, " length: ", v1.length())
				bounce(m1, m2, v1, v2, cor)
				if _debug_out: print(name, " vel after bounce: ", _velocity, " length: ", _velocity.length())
				stop_at_rest()

			else:
				# use Godot integrated physics
				if _debug_out: print(name, " vel before bounce: ", _velocity, " length: ", _velocity.length())
				_velocity = _velocity.bounce(collision.normal) * 0.5
				#var remaining_vel = collision.remainder
				#_velocity = remaining_vel.bounce(collision.normal)
				if _debug_out: print(name, " vel after bounce: ", _velocity, " length: ", _velocity.length())
				# this should stop the object from moving, which should stop colliding, which should stop endlessly adding gravity
				# should actually happen if drag is working correctly
				stop_at_rest()

	# destroy bullet after given lifetime
	_alive += delta
	if _alive > max_lifetime:
		queue_free()
