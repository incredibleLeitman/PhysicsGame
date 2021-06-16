extends KinematicBody2D
class_name Pawn


var _mass := 1.0
var _speed := 0.0
var _velocity := Vector2.ZERO

var ground_velocity := Vector2.ZERO # velocity for ground, platform, etc...

export var MAX_SPEED := Vector2(500, 2000)


func apply_gravity(delta: float) -> void:
	_velocity.y += Constants.GRAVITY * _mass * delta

func add_force(force: Vector2) -> void:
	_velocity = force
