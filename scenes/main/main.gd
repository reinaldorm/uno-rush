extends Node2D
class_name Main

@export var camera : Camera2D

var delta_count := 0.0

func _process(delta: float) -> void:
	delta_count += delta
	
	camera.offset = Vector2(cos(delta_count  * 0.75) * 1.5, sin(delta_count  * 0.75) * 1.5)
	camera.offset
