#extends "res://Player/Pawn.gd"
extends Pawn


func _ready() -> void:
	set_physics_process(false)
	_velocity.x = -Constants.MOVE_ACCELERATION.x * 100


func _physics_process(delta: float) -> void:

	if is_on_wall():
		print("hit a wall")
		_velocity.x *= -1
