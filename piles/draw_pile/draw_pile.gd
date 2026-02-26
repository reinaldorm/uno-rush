extends Node2D
class_name DrawPile

signal draw_requested()

@export var card_scene: PackedScene

@export var animation_player: AnimationPlayer

var _tween: Tween

# -------------------------
# Public API
# -------------------------

func confirm_draw() -> void:
	print("DrawPile: Draw Confirmed")

func deny_draw() -> void:
	print("DrawPile: Draw Denied")

func update_draw_stack(new_stack: int) -> void:
	pass

# -------------------------
# Internal
# -------------------------

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
	animation_player.play("hover")

func _on_button_mouse_exited() -> void:
	animation_player.play_backwards("hover")

func _on_button_pressed() -> void:
	emit_signal("draw_requested")
