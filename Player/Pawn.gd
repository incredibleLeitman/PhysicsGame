extends KinematicBody2D
class_name Pawn


var _mass := 1.0
var _speed := 0.0
var _velocity := Vector2.ZERO

var ground_velocity := Vector2.ZERO # velocity for ground, platform, etc...

export var MAX_SPEED := Vector2(500, 2000)

func _physics_process(delta: float) -> void:

	# TODO: FIXME
	return

	# adapt velocity from ground
	_velocity = lerp(_velocity, ground_velocity, Constants.MOVE_DRAG)

	# apply forces like gravity
	_velocity.y += Constants.GRAVITY * _mass * delta
	
	# set max speed
	_velocity.x = clamp(_velocity.x, -MAX_SPEED.x, MAX_SPEED.x)
	_velocity.y = clamp(_velocity.y, -MAX_SPEED.y, MAX_SPEED.y)

	_velocity = move_and_slide(_velocity, Vector2.UP)
