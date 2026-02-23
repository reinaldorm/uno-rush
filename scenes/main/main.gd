@tool
extends Node2D
class_name Main

@export var camera : Camera2D
@export var turn_arrow : Sprite2D

var delta_count := 0.0

func _process(delta: float) -> void:
	delta_count += delta
	_idle()

func _idle() -> void:
	var m_offset = (get_global_mouse_position() - camera.global_position) * 0.01
	camera.offset = camera.offset.lerp( Vector2(cos(delta_count  * 0.75) * 1.5, sin(delta_count  * 0.75) * 1.5) + m_offset, 0.1)
	turn_arrow.rotation = delta_count * 0.1
