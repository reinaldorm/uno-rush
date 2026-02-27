extends Node2D
class_name DrawPile

signal draw_requested()

@export var _card_view_scene: PackedScene
@export var _top_sprite: Sprite2D
@export var _animation_player: AnimationPlayer
@export var _views_node = Node2D

var _views_arr : Array[CardView] = []
var _draw_stack: int = 0
var _tween: Tween
var _tick := 0.0

# -------------------------
# Public API
# -------------------------

func setup() -> void:
	pass

func confirm_draw() -> void:
	print("DrawPile: Draw Confirmed")

func deny_draw() -> void:
	print("DrawPile: Draw Denied")

func update_draw_stack(new_stack: int) -> void:
	if new_stack == _draw_stack: return

	for i in range(new_stack):
		var view = _card_view_scene.instantiate()
		view.position = Vector2(0, i * 50)
		_views_node.add_child(view)

# -------------------------
# Internal
# -------------------------

func _idle(delta: float) -> void:
	_views_node.rotation += _tick

	var angle_up := _views_node.get_angle_to(Vector.UP)

	for view in _views_arr: 
		view.rotation = angle_up

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
