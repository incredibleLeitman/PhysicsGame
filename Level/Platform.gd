extends Node2D


export var animation := "stop"


func _ready() -> void:
	$AnimationPlayer.current_animation = animation
