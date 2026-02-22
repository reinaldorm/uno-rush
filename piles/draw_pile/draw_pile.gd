extends Node2D
class_name DrawPile

@export var sprite_2d: Sprite2D

var _tween: Tween

# -------------------------
# Internal
# -------------------------

func _animate_entered() -> void:
	var tween := _new_tween()
	
	tween.set_parallel()
	tween.tween_property(sprite_2d, "position:y", -15, 0.5)
	_tween.tween_method(func(value: float):
		sprite_2d.material.set_shader_parameter("x_rot", value),
		sprite_2d.material.get_shader_parameter("x_rot"),
		0.0,
		0.5)

func _animate_exited() -> void:
	var tween := _new_tween()
	
	tween.set_parallel()
	tween.tween_property(sprite_2d, "position:y", 0, 0.5)
	_tween.tween_method(func(value: float):
		sprite_2d.material.set_shader_parameter("x_rot", value),
		sprite_2d.material.get_shader_parameter("x_rot"),
		7.5,
		0.5)

func _new_tween(e:= Tween.EASE_OUT, t:= Tween.TransitionType.TRANS_EXPO) -> Tween:
	if _tween: _tween.kill()

	_tween = create_tween()
	_tween.set_ease(e)
	_tween.set_trans(t)
	
	return _tween

# -------------------------
# Handlers
# -------------------------

func _on_button_mouse_entered() -> void:
	_animate_entered()

func _on_button_mouse_exited() -> void:
	_animate_exited()
