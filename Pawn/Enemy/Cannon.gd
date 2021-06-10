#extends "res://Player/Pawn.gd"
extends Pawn


export var delay := 3.0 # time between shots


var _rotation := 0.0
var _reset := 0.0

# TODO: move to Pawn BaseClass
func _ready() -> void:
	set_physics_process(false)


func _physics_process(delta: float) -> void:
	$CollisionShapeTop.rotate(_rotation + delta)
	_reset += delta
	if _reset > delay:
		print("TODO: implement cannon shoot!")
		_reset = 0
