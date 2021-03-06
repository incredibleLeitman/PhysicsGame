extends KinematicBody2D

export(NodePath) var player_node
onready var player = get_node(player_node)

export var delay := 6.0 # time between shots
export var speed = 1000.0 # projectile speed
export var g := Constants.GRAVITY

onready var bomb_scene = preload("res://Pawn/Enemy/Bomb.tscn")
onready var muzzle = $CollisionShapeTop/SpriteCrosshair
onready var aim_curve = $Line2D
onready var v2 = speed * speed

var _velocity := Vector2.ZERO
var _reset := 0.0


func _ready() -> void:
	set_physics_process(false)

	# if player was not assigned in inspector
	if not player: player = get_parent().get_parent().get_node("Player")


func _physics_process(delta: float) -> void:

	aim_curve.clear_points()

	# target player
	var pos = player.global_position
	if abs(pos.x - global_position.x) > 200 or abs(pos.y - global_position.y) > 400:

		var x = pos.x - muzzle.global_position.x
		var y = -pos.y - muzzle.global_position.y

		#var a = (g * x*x) / (2 * v2)
		#var b = x
		#var c = a + y

		# solve quadratic equation for theta
		# shamelessly stolen from the great Alex Rose who used this in RudeBear
		# "Physics for Unity - 22: SUVAT Equations and 3D Projectile Prediction"
		# I tried to derive the formula myself but failed miserably -.-
		var quotient = v2*v2 - g*g * x*x - 2 * v2*y*g
		#var quotient = b*b - 4*a*c
		if quotient > 0:

			_reset += delta

			var result = (v2 - sqrt(quotient)) / (g*x)
			#var result = (-b - sqrt(quotient)) / (2*a)
			var angle = atan(result)

			_velocity = Vector2(
				(1 if x > 0 else -1) * speed * cos(angle),
				(1 if x > 0 else -1) * speed * sin(angle)
			)

			_draw_curve()

			$CollisionShapeTop.rotation = angle + (PI if x < 0 else 0.0)

			if _reset > delay:
				# wait 0.5 seconds then fire more bombs
				#for i in range(0, 3):
					#yield(get_tree().create_timer(0.5), "timeout")
					_shoot()

			return

	# if player is in close-range or cannot be reached continue rotating
	$CollisionShapeTop.rotation += delta
	_reset = 0

func _draw_curve() -> void:

	aim_curve.global_position = muzzle.global_position
	for idx in range(0, 500):

		var t = idx * get_physics_process_delta_time()

		var sx = _velocity.x * t
		var sy = _velocity.y * t + 0.5 * g * t*t

		aim_curve.add_point(Vector2(sx, sy))

func _shoot() -> void:

	var instance = bomb_scene.instance()
	instance.position = muzzle.global_position
	instance.initial_velocity = _velocity
	get_parent().add_child(instance) # add to enemy group

	_reset = 0

func _on_VisibilityEnabler2D_screen_exited() -> void:
	aim_curve.clear_points()
