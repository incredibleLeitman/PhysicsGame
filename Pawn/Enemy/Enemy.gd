#extends "res://Player/Pawn.gd"
extends Pawn


# TODO: move to Pawn BaseClass
func _ready() -> void:
	set_physics_process(false)


func _physics_process(delta: float) -> void:
	pass
