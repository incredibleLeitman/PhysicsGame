extends KinematicBody2D
class_name Pawn


var _mass := 1.0
var _speed := 0.0
var _velocity := Vector2.ZERO

var _is_on_floor := false
var _is_in_rest := false

var ground_velocity := Vector2.ZERO # velocity for ground, platform, etc...

var collision_handled := false # flag to indicate that another object already handled the collision

export var MAX_SPEED := Vector2(500, 2000)


func apply_gravity(delta: float) -> void:
	_velocity.y += Constants.GRAVITY * _mass * delta

func add_force(force: Vector2) -> void:
	_velocity = force

func bounce(m1: float, m2: float, v1: Vector2, v2: Vector2, cor: float) -> void:
	var bounce_velocity = (m1*v1 + m2*v2 + m2*cor*(v2 - v1)) / (m1+m2)
	# if collision with non-moving object
	if v2.is_equal_approx(Vector2.ZERO):
		print("aproximately zero")
		#bounce_velocity.x *= sign(v1.x) * -1
		bounce_velocity.x *= -1
	add_force(bounce_velocity)

func stop_at_rest():
	if _velocity.length() < 12:
		print(name, " -> should stop movement")
		_velocity = Vector2.ZERO
		_is_in_rest = true
	else:
		_is_in_rest = false
