extends Node2D
class_name Main

@export var camera : Camera2D
@export var color_rect : ColorRect

var _tick := 0.0
var _tween : Tween

# -------------------------
# Internal
# -------------------------

func _process(delta: float) -> void:
	_tick += delta

func _idle() -> void:
	var m_offset = (get_global_mouse_position() - camera.global_position) * 0.01
	camera.offset = camera.offset.lerp( Vector2(cos(_tick  * 0.75) * 1.5, sin(_tick  * 0.75) * 1.5) + m_offset, 0.1)
