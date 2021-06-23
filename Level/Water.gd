extends Area2D


func _ready() -> void:
	pass


func _on_Area2D_body_entered(body: Node) -> void:
	if body.has_method("set_drag"):
		body.set_drag(Vector2(Constants.WATER_DRAG, 0))

	if body.has_method("set_gravity"):
		body.set_gravity(Constants.GRAVITY / 3.0)


func _on_Area2D_body_exited(body: Node) -> void:
	if body.has_method("set_drag"):
		body.set_drag(Vector2(Constants.MOVE_DRAG, 0))

	if body.has_method("set_gravity"):
		body.set_gravity(Constants.GRAVITY)
