extends Node2D
class_name TurnCard

var _tween : Tween
var _pos : Vector2

# -------------------------
# Public API
# -------------------------

func setup(p: Vector2) -> void:
	_pos = p

func show_card() -> void:
	_animate_pos(_pos.y - 50)

func hide_card() -> void:
	_tween = TweenHelper.new_tween(_tween, self)
	_animate_pos(_pos.y + 50)

# -------------------------
# Internal
# -------------------------

func _animate_pos(y: float) -> void:
	_tween = TweenHelper.new_tween(_tween, self)

	_tween.tween_property(self, "position:y", y, 1.0)
	
