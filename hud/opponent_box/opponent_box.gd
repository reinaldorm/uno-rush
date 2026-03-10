extends Control
class_name OpponentBox

@export var name_label: RichTextLabel
@export var cards_label: RichTextLabel
@export var turn_sprite: Node2D

var _tween : Tween

# -------------------------
# Public API
# -------------------------

func update_name(_name: String) -> void:
	name_label.text = _name

func update_cards(count: int) -> void:
	cards_label.text = str(count)

func update_turn(turn: bool) -> void:
	if turn:
		show_turn()
	else:
		hide_turn()

func show_turn() -> void:
	_tween = TweenHelper.new_tween(_tween, self).set_trans(Tween.TRANS_ELASTIC)

	_tween.tween_property(turn_sprite, "position:x", 35.0, 1)

func hide_turn() -> void:
	_tween = TweenHelper.new_tween(_tween, self).set_trans(Tween.TRANS_ELASTIC)

	_tween.tween_property(turn_sprite, "position:x", 25.0, 1)

# -------------------------
# Internal
# -------------------------
