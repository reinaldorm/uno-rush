extends Node2D
class_name DrawPile

signal draw_requested()

@export var _card_scene: PackedScene
@export var _top_sprite: Sprite2D
@export var _animation_player: AnimationPlayer


var _draw_stack: int = 0
var _tween: Tween

# -------------------------
# Public API
# -------------------------

func confirm_draw() -> void:
	print("DrawPile: Draw Confirmed")

func deny_draw() -> void:
	print("DrawPile: Draw Denied")

func update_draw_stack(new_stack: int) -> void:
	for i in range(new_stack):
		var card = _card_scene.instantiate()
		card.position = Vector2(0, i * 50)
		add_child(card)

# -------------------------
# Internal
# -------------------------

# -------------------------
# Handlers
# -------------------------

func _on_button_mouse_entered() -> void:
	_animation_player.play("hover")

func _on_button_mouse_exited() -> void:
	_animation_player.play_backwards("hover")

func _on_button_pressed() -> void:
	emit_signal("draw_requested")

func _on_camera_shake() -> void:
	var tween = TweenHelper.new_tween(_tween, self).set_ease(Tween.EASE_OUT).set_trans(Tween.TransitionType.TRANS_QUINT)

	_top_sprite.scale = Vector2(2.75, 2.75)
	tween.tween_property(_top_sprite, "scale", Vector2(2.5, 2.5), 0.5)
