extends Pawn


export(Vector2) var initial_velocity := Vector2(1000, -500)
export var max_lifetime := 3.0 # time before despawning in s
export var explosion_force := Vector2(3000, 1000) # how much an explosion moves objects

onready var radius = $Area2D/CollisionShape2D.shape.radius * scale.x # need to be a circle to work correctly

var _alive := 0.0 # determine current lifetime
var _close_pawns = [] # array of pawn in explosion range
var _timer := 1.0 # timer before exploding
var _stop_moving := false # dont move explosion sprite
var _debug_out := false


func _ready() -> void:
	_velocity = initial_velocity

func _physics_process(delta: float) -> void:

	if not _stop_moving:
		_handle_movement(delta)
	
	_alive += delta
	# modulate red for explosion timer
	if _alive > _timer:
		var val = fmod($Sprite.modulate.g8 + 10, 255)/255
		$Sprite.modulate = Color(1, val, val)
	# destroy bullet after given lifetime
	if _alive > max_lifetime:
		explode()


func _handle_movement(delta: float) -> void:

	if not is_on_floor() and not _is_in_rest:
		apply_gravity(delta)

	# using move and collide to get collsion
	var collision = move_and_collide(_velocity * delta)
	# using move and slide and manually search for collisions
	#_velocity = move_and_slide(_velocity)
	#var slide_count = get_slide_count()
	#var collision = get_slide_collision(slide_count - 1) if slide_count else null
	if collision and collision.collider:

		if collision.collider is Enemy:
			# skipping basic enemy type
			pass
			collision_handled = false
		else:

			# bounce off obstacles
			# material 		COR
			# zinc, nickel	0.15
			# glass			0.69
			# silicon		1.79

			if collision.collider is Pawn:

				var pawn := collision.collider as Pawn

				var m1 = mass
				var m2 = pawn.mass
				var v1 = _velocity
				var v2 = pawn._velocity

				# handle other object bounce if its not a wall or RigidBody
				# could also store values before collision and aply after next tick
				# to that the collider use the same values before modifications
				if _debug_out: print(pawn.name, " vel before bounce: ", v2, " length: ", v2.length())
				pawn.collide(m2, m1, v2, v1)
				pawn.collision_handled = true # mark as handled so that the object itself does not bounce
				if _debug_out: print(pawn.name, " vel after bounce: ", pawn._velocity, " length: ", pawn._velocity.length())

				# handle own bounce
				if _debug_out: print(name, " vel before bounce: ", v1, " length: ", v1.length())
				if v2.is_equal_approx(Vector2.ZERO):
					bounce(collision.normal)
				else:
					collide(m1, m2, v1, v2)
				if _debug_out: print(name, " vel after bounce: ", _velocity, " length: ", _velocity.length())

			else:
				if _debug_out: print(name, " vel before bounce: ", _velocity, " length: ", _velocity.length())
				#var remaining_vel = collision.remainder
				#_velocity = remaining_vel.bounce(collision.normal)
				bounce(collision.normal)
				if _debug_out: print(name, " vel after bounce: ", _velocity, " length: ", _velocity.length())


func explode (force = Vector2.ZERO) -> void:

	_stop_moving = true
	max_lifetime = INF # stop from re-exploding

	$Sprite.visible = false
	$SpriteBoom.visible = true
	$AudioStreamPlayer2D.play()
	var tween = get_node("Tween")
	tween.interpolate_property($SpriteBoom, "scale",
		Vector2(0.2, .2), Vector2(1, 1), 1.0,
		Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	tween.interpolate_property($SpriteBoom, "modulate", 
		Color(1, 1, 1, 1), Color(1, 1, 1, 0), 1.0, 
		Tween.TRANS_LINEAR, Tween.EASE_IN)
	tween.start()

	if _close_pawns.size() > 0:
		for pawn in _close_pawns:
			var dist = pawn.position - position
			# shorten vector to calc from bomb border to player
			var dist_length = dist.length()
			var border = $CollisionShape2D.shape.radius * scale.x
			dist = dist * (1 - border/dist_length)
			
			var force_factor = abs(1.0 / (radius / (radius - dist.length())))
			force += force_factor * dist.normalized() * explosion_force * mass
			if _debug_out: print(name, " applying for to ", pawn.name, " -> applying explosion force: ", force, " with force factor: ", force_factor, " for dist_lengh: ", dist_length)
			# trigger explosion of other bombs
			if pawn.has_method("explode"):
				_close_pawns.erase(pawn)
				pawn.exclude_pawn(self)
				pawn.explode(force)
			# force player movement
			else:
				pawn.add_force(force)


func exclude_pawn(body: Node) -> void:
	_close_pawns.erase(body)


func _on_Tween_tween_all_completed() -> void:
	queue_free()


func _on_Area2D_body_entered(body: Node) -> void:
	if body is Pawn and body != self:
		_close_pawns.append(body)


func _on_Area2D_body_exited(body: Node) -> void:
	if body is Pawn:
		_close_pawns.erase(body)
