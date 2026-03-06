extends Node2D
class_name TurnArrow

@export var sprite_2d: Sprite2D

var _tween : Tween
var _tween_idle : Tween
# -------------------------
# Public Api ##############
# -------------------------

func start() -> void:
	pass

func turn(direction: Vector2) -> void:
	_tween = TweenHelper.new_tween(_tween, self)

	_tween.set_ease(Tween.EASE_OUT)
	_tween.set_trans(Tween.TransitionType.TRANS_QUINT)

	_tween.tween_property(self, "rotation", rotation + get_angle_to(direction), 1.5)

# -------------------------
# Internal ################
# -------------------------

func _ready() -> void:
	_idle()

func _idle() -> void:
	_tween_idle = TweenHelper.new_tween(_tween_idle, self).set_trans(Tween.TRANS_LINEAR)

	_tween_idle.tween_property(sprite_2d, "rotation", 0.05, 0.5)
	_tween_idle.tween_property(sprite_2d, "rotation", 0.0, 0.5)
	_tween_idle.tween_property(sprite_2d, "rotation", -0.05, 0.5)
	_tween_idle.tween_property(sprite_2d, "rotation", 0.0, 0.5)

	_tween_idle.set_loops()



