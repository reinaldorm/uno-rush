@tool
extends Node2D
class_name Main

@export var camera : Camera2D
@export var turn_arrow : Sprite2D

var _tick := 0.0
var _tween : Tween

func _process(delta: float) -> void:
	_tick += delta
	_idle()

func _idle() -> void:
	var m_offset = (get_global_mouse_position() - camera.global_position) * 0.01
	camera.offset = camera.offset.lerp( Vector2(cos(_tick  * 0.75) * 1.5, sin(_tick  * 0.75) * 1.5) + m_offset, 0.1)
	turn_arrow.rotation = _tick * 0.1

func _zoom_to_pos(pos: Vector2) -> void:
	if _tween: _tween.kill()
	_tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO).set_parallel()
	_tween.tween_property(camera, "zoom", Vector2(2.0, 2.0), 1)
	_tween.tween_property(camera, "global_position", pos, 1)
	
func _on_draw_pile_draw_requested() -> void:
	_zoom_to_pos($DrawPile.global_position + Vector2(0, 25))
