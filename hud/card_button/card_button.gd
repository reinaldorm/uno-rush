extends Button
class_name CardButton

signal on_button_pressed

@export var card_sprite : Sprite2D
@export var state_transform : Node2D
@export var hover_transform : Node2D
@export var press_transform : Node2D

var _tween_hover : Tween
var _tween_press : Tween
var _tween_state : Tween

var _disabled := false

## Public Api

func enable() -> void:
	_disabled = false

	_tween_state = TweenHelper.new_tween(_tween_state, self).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)
	_tween_state.set_parallel()

	_tween_state.tween_property(state_transform, "position:y", 0.0, 1.0)
	_tween_state.tween_property(card_sprite, "modulate:a", 1.0, 1.0)

func disable() -> void:
	_disabled = true

	_tween_state = TweenHelper.new_tween(_tween_state, self).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)
	_tween_state.set_parallel()

	_tween_state.tween_property(state_transform, "position:y", 10.0, 1.0)
	_tween_state.tween_property(card_sprite, "modulate:a", 0.5, 1.0)
	_animate_hover(false)

## Internal

func _animate_hover(enter: bool) -> void:
	_tween_hover = TweenHelper.new_tween(_tween_hover, self)
	_tween_hover.set_trans(Tween.TRANS_ELASTIC)
	_tween_hover.set_ease(Tween.EASE_OUT)

	if enter:
		_tween_hover.tween_property(hover_transform, "scale", Vector2(1.1, 1.1), 0.75)
	else:
		_tween_hover.tween_property(hover_transform, "scale", Vector2(1.0, 1.0), 0.75)

func _animate_press() -> void:
	_tween_press = TweenHelper.new_tween(_tween_press, self).set_parallel()
	_tween_press.set_trans(Tween.TRANS_ELASTIC)
	_tween_press.set_ease(Tween.EASE_OUT)

	press_transform.scale = Vector2(1.15, 1.15)
	press_transform.rotation = randf_range(-0.25, 0.25)

	_tween_press.tween_property(press_transform, "scale", Vector2(1.0, 1.0), 1.0)
	_tween_press.tween_property(press_transform, "rotation", 0.0, 1.5)

## Handlers

func _on_button_pressed() -> void:
	if _disabled: return

	_animate_press()
	emit_signal("on_button_pressed")

func _on_button_entered() -> void:
	if _disabled: return

	_animate_hover(true)

func _on_button_exited() -> void:
	if _disabled: return

	_animate_hover(false)
