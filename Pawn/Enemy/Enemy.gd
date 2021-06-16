#extends "res://Player/Pawn.gd"
extends Pawn


func _ready() -> void:
	_velocity.x = -MAX_SPEED.x/2
	set_physics_process(false)


func _physics_process(delta: float) -> void:

	if not is_on_floor():
		apply_gravity(delta)

	if is_on_wall():
		_velocity.x *= -1
	_velocity.y = move_and_slide(_velocity, Vector2.UP).y
