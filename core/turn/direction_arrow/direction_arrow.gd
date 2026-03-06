extends Node2D
class_name DirectionArrow

@export var _sprite_2d : Sprite2D

var _tween: Tween
var _tick := 0.0

func start() -> void:
	pass

func reverse(_direction: int) -> void:
	_tween = TweenHelper.new_tween(_tween, self)

	_tween.set_ease(Tween.EASE_OUT)
	_tween.set_trans(Tween.TransitionType.TRANS_QUINT)

	_tween.tween_property(_sprite_2d, "rotation", _sprite_2d.rotation + PI/2, 1.0)

func _process(delta: float) -> void:
	_tick += delta

	_idle()

func _idle():
	rotation = _tick * 0.1
