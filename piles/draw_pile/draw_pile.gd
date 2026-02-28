extends Node2D
class_name DrawPile

signal draw_requested()

@export var _card_view_scene: PackedScene
@export var _top_sprite: Sprite2D
@export var _animation_player: AnimationPlayer
@export var _views_node : Node2D

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
		var view : CardView = _card_view_scene.instantiate()

		view.set_flip(true)

		view.scale = Vector2(0.0, 0.0)

		_views_node.add_child(view)
		_views_arr.append(view)

	_tween = TweenHelper.new_tween(_tween, self).set_parallel()
	_tween.set_trans(Tween.TRANS_ELASTIC)
	_tween.set_ease(Tween.EASE_OUT)

	for i in range(_views_arr.size()):
		var view = _views_arr[i]
		add_view_to_stack(view)
		_tween.tween_property(view, "scale", Vector2(0.5, 0.5), 1.0).set_delay(i * 0.05)

# -------------------------
# Internal
# -------------------------

func _process(delta: float) -> void:
	_tick += delta

	_idle()

func _idle() -> void:
	_views_node.rotation = _tick

	for view in _views_arr:
		view.rotation = -_views_node.rotation

func add_view_to_stack(view: CardView) -> void:
	var angle_dif = TAU / _views_arr.size()

	view.position = Vector2(
		cos(angle_dif * _views_arr.find(view)) * 40,
		sin(angle_dif * _views_arr.find(view)) * 40
	)

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
