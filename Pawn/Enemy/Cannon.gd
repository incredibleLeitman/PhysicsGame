#extends "res://Player/Pawn.gd"
extends Pawn

export(NodePath) var player_node
onready var player = get_node(player_node)

export var delay := 3.0 # time between shots

var bullet_scene = preload("res://Pawn/Enemy/Bullet.tscn")

var _rotation := 0.0
var _reset := 0.0


func _ready() -> void:
	set_physics_process(false)


func _physics_process(delta: float) -> void:
	_reset += delta
	if _reset > delay:
		shoot()
	elif _reset > 1.0:
		$CollisionShapeTop.rotate(_rotation + delta)



func shoot() -> void:
	_reset = 0

	var pos = player.get_position()

	# look at current player position
	$CollisionShapeTop.look_at(pos)

	var instance = bullet_scene.instance()
	instance.position = $CollisionShapeTop/icon.global_position
	instance.initial_velocity.x *= sign(pos.x - self.position.x)
	get_tree().get_root().add_child(instance)
