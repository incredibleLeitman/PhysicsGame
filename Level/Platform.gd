extends KinematicBody2D

export var speed := 150.0
export var mode := 0 # TODO enum hor, ver, diag, sin...
export var distance := 300

var _start_pos = Vector2.ZERO
var _dir := Vector2.ZERO

func _ready() -> void:
	_start_pos = position
	if mode == 0:
		_dir = Vector2(sign(distance), 0)
		distance = distance / scale.x
	elif mode == 1:
		_dir = Vector2(0, sign(distance))
		distance = distance / scale.y

func _physics_process(delta: float) -> void:
	position += speed * _dir * delta
	if mode == 0:
		if position.x > _start_pos.x + distance:
			_dir = Vector2(-1, 0)
		elif position.x < _start_pos.x - distance:
			_dir = Vector2(+1, 0)
	elif mode == 1:
		if position.y > _start_pos.y + abs(distance):
			_dir = Vector2(0, -1)
		elif position.y < _start_pos.y - abs(distance):
			_dir = Vector2(0, +1)

func get_ground_velocity () -> Vector2:
	return speed * _dir
