extends Area2D


func _ready() -> void:
	pass


func _on_Area2D_body_entered(body: Node) -> void:
	print("on body entered: ", body.name)


func _on_Area2D_body_exited(body: Node) -> void:
	print("on body exit: ", body.name)
