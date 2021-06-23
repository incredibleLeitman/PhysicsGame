extends KinematicBody2D
class_name Pawn


export var cor := 0.5 # coefficient of restitution (bounciness)
export var mass := 1.0

var _speed := 0.0
var _velocity := Vector2.ZERO
var _is_in_rest := false

onready var ground_velocity := Vector2.ZERO # velocity for ground, platform, etc...
onready var _drag := Vector2(Constants.MOVE_DRAG, 0)

var collision_handled := false # flag to indicate that another object already handled the collision


func _physics_process(delta: float) -> void:
	# this should stop the object from moving, which should stop colliding, which should stop endlessly adding gravity
	# should actually happen if drag is working correctly
	stop_at_rest()

func get_ground_velocity() -> Vector2:
	return _velocity

func set_drag(drag : Vector2) -> void:
	print(name, " -> setting drag to: ", drag)
	_drag = drag
	print(name, " -> setting drag to: ", _drag)

func apply_gravity(delta: float) -> void:
	_velocity.y += Constants.GRAVITY * mass * delta

func apply_drag():
	_velocity.x = lerp(_velocity.x, ground_velocity.x, _drag.x)
	_velocity.y = lerp(_velocity.y, ground_velocity.y, _drag.y)

func add_force(force: Vector2) -> void:
	_velocity += force

# used to bounce away from an non-moving object
func bounce(normal: Vector2) -> void:
	_velocity = -(2.0 * normal * _velocity.dot(normal) - _velocity) * cor

# used for two moving objects to bounce of each other
func collide(m1: float, m2: float, v1: Vector2, v2: Vector2) -> void:
	_velocity = (m1*v1 + m2*v2 + m2*cor*(v2 - v1)) / (m1+m2)

func stop_at_rest():
	if _velocity.length() < 12:
		#print(name, " -> should stop movement")
		_velocity = Vector2.ZERO
		_is_in_rest = true
	else:
		_is_in_rest = false
