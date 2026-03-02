class_name LayoutComponent
extends Node

@export var curve_x : Curve
@export var curve_y : Curve
@export var curve_rot : Curve

@export var mult_y : float = 25
@export var mult_rot : float = 0.25

@export var max_arrange_width := 400.0
@export var min_arrange_width := 100.0
@export var	arrange_gap := 20.0

var _tween : Tween

signal arrange_ended()

# -------------------------
# Public API
# -------------------------

func request_arrange(cards: Array[CardView]) -> Signal:
	_arrange(cards)
	return arrange_ended

func request_arrange_new(cards: Array[CardView], new_cards: Array[CardView]) -> Signal:
	_arrange_new(cards, new_cards)
	return arrange_ended

# -------------------------
# Internal
# -------------------------

func _arrange(cards: Array[CardView]) -> void:
	var active_cards : Array[CardView] = []

	for c in cards: active_cards.append(c)

	var total := active_cards.size()
	if total == 0: return

	for i in range(total):
		var card := active_cards[i]
		if not card: continue

		var ratio := 0.5 if total == 1 else _get_ratio(i, total - 1)
		var final_card_width : float = (min(card.size.x * total, max_arrange_width) - card.size.x) / 2

		var final_position := Vector2(curve_x.sample(ratio) * final_card_width, -curve_y.sample(ratio) * mult_y)
		var final_rotation := curve_rot.sample(ratio) * mult_rot

		if card.is_selected: final_position.y -= 10.0

		var tween = card.animate("layout", Tween.EASE_OUT, Tween.TRANS_EXPO).set_parallel()

		card.z_index = i

		tween.tween_property(card, "position", final_position, 0.5)
		tween.tween_property(card, "scale", Vector2.ONE, 0.5)
		tween.tween_property(card, "rotation", final_rotation, 0.5)

	emit_signal("arrange_ended")

func _arrange_new(cards: Array[CardView], new_cards: Array[CardView]) -> void:
	var cards_but_new : Array[CardView]

	for card in cards:
		if not new_cards.has(card): cards_but_new.append(card)
		else: cards_but_new.append(null)

	_arrange(cards_but_new)

	var total := new_cards.size()
	var tweens : Array[Tween] = []

	for i in range(total):
		var card = new_cards[i]

		var ratio := 0.5 if total == 1 else _get_ratio(i, total - 1)
		var final_card_width : float = (min(card.size.x * total, max_arrange_width) - card.size.x) / 2

		var final_rotation := curve_x.sample(ratio) * mult_rot
		var final_position := Vector2(curve_x.sample(ratio) * final_card_width, -curve_y.sample(ratio) * mult_y - 70)

		var tween = card.animate("layout", Tween.EASE_OUT, Tween.TRANS_EXPO).set_parallel()
		tweens.append(tween)

		tween.tween_property(card, "scale", Vector2(1.0, 1.0), 0.75)
		tween.tween_property(card, "rotation", final_rotation, 0.75)
		tween.tween_property(card, "position", final_position, 0.75)
		await card.animate_flip()

	await get_tree().create_timer(0.75).timeout

	emit_signal("arrange_ended")

func _get_ratio(value: float, of: float) -> float:
	return value / of
