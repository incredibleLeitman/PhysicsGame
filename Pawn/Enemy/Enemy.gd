#extends "res://Player/Pawn.gd"
extends Pawn
class_name Enemy


func _ready() -> void:
	_velocity.x = -250
	set_physics_process(false)

func _physics_process(delta: float) -> void:

	if not is_on_floor():
		apply_gravity()

	if is_on_wall():
		_velocity.x *= -1

	var _new_velocity = move_and_slide(_velocity, Vector2.UP)
