extends Node2D

var _velocity := Vector2.ZERO
var _rotate_point := Vector2.ZERO
var _time := 0.0

export var speed = 3.0
export var radius = 250.0

func _physics_process(delta: float) -> void:
	
	# mark 1 - direct on player
	#var player = get_parent() as Node2D
	#_velocity += (player.global_position - global_position) * 0.1 / delta
	#print("player pos: ", player.global_position, " <-> pos: ", global_position, " --> vel: ", _velocity)
	#_velocity = move_and_slide(_velocity, Vector2.UP)
	#print("move vel: ", _velocity)
	
	# mark 2 - following rotate point
	_time += delta*speed
	_rotate_point = Vector2(cos(_time) * radius, sin(_time) * radius)
	$icon.position = _rotate_point
	$icon.rotation = _rotate_point.angle_to_point(Vector2.ZERO) + PI/2
	
	var actual_shield = $KinematicBody2D
	actual_shield.position += (_rotate_point - actual_shield.position) * 0.5
	actual_shield.rotation = actual_shield.position.angle_to_point(Vector2.ZERO) + PI/2
	#_velocity += (_rotate_point - position) * 0.1 / delta
	#_velocity = move_and_slide(_velocity, Vector2.UP)
