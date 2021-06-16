extends Pawn


export(Vector2) var initial_velocity := Vector2(2*MAX_SPEED.x, -500)
var max_lifetime := 7.0 # time before despawning in s ( = double the cannon shoot delay)
var cor := 0.2 # coefficient of restitution (bounciness)

var _alive := 0.0


func _ready() -> void:
	#_mass = 0.1
	_velocity = initial_velocity

func _physics_process(delta: float) -> void:

	if not is_on_floor():
		apply_gravity(delta)

	#_velocity = move_and_slide(_velocity, Vector2.UP)
	var collision = move_and_collide(_velocity * delta)
	if collision:
		# bounce off obstacles
		# material 		COR
		# zinc, nickel	0.15
		# glass			0.69
		# silicon		1.79
		#var full_vel = (m1*_velocity + m2*v2 + m2*cor*(v2 - _velocity)) / (m1+m2))
		#var red_vel = (_velocity - cor * _velocity) / 2)
		var normal = collision.normal
		#var dot_vel = cor * (_velocity - 2 * _velocity.dot(normal) * normal)

		# TODO: calculate full direction (also y axis)
		var vel_sign = sign(_velocity.x)
		#_velocity = (_velocity - cor * _velocity)/2 * Vector2(vel_sign * normal.x, normal.y)
		
		var m1 = 1
		var m2 = 1
		var v2 = Vector2.ZERO
		if collision.collider.name == "Player" or collision.collider.name.begins_with("Bullet"):
			m2 = collision.collider._mass
			v2 = collision.collider._velocity

			var bounce_vel = (m1*_velocity + m2*v2 + m1*cor*(_velocity - v2)) / (m1+m2)
			var dir = Vector2(-vel_sign * normal.x, vel_sign * normal.y)
			collision.collider.add_force(bounce_vel * dir)

		# handle own bounce
		var bounce_vel = (m1*_velocity + m2*v2 + m2*cor*(v2 - _velocity)) / (m1+m2)
		var dir = Vector2(vel_sign * normal.x, normal.y)
		_velocity = bounce_vel * dir

	# destroy bullet after given lifetime
	_alive += delta
	if _alive > max_lifetime:
		queue_free()
