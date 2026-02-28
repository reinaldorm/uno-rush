extends Node2D
class_name Main

@export var camera : Camera2D
@export var color_rect : ColorRect


@export var turn_arrow : Sprite2D
var turn_rotation : float = 0.0

var _tick := 0.0
var _tween : Tween

# -------------------------
# Internal
# -------------------------

func _process(delta: float) -> void:
	_tick += delta
	_idle()

	turn_arrow.rotation += delta * 0.1

func _idle() -> void:
	var m_offset = (get_global_mouse_position() - camera.global_position) * 0.01
	camera.offset = camera.offset.lerp( Vector2(cos(_tick  * 0.75) * 1.5, sin(_tick  * 0.75) * 1.5) + m_offset, 0.1)

# -------------------------
# Animations
# -------------------------

func _animate_turn_advance(_direction: int) -> void:
	print("Main: Animating turn arrow")

# -------------------------
# Handlers
# -------------------------

func _on_draw_pile_draw_requested() -> void:
	#_zoom_to_pos($DrawPile.global_position + Vector2(0, 25))
	pass

func _on_turn_manager_turn_advanced(direction: int) -> void:
	_animate_turn_advance(direction)
