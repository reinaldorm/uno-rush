 class_name HandLayoutComponent
extends Node

@export var curve_x : Curve
@export var curve_y : Curve
@export var curve_rot : Curve

@export var mult_y : float = 25
@export var mult_rot : float = 0.25

@export var max_arrange_width := 400.0
@export var min_arrange_width := 100.0
@export var	arrange_gap := 20.0

signal arrange_ended()

# -------------------------
# Public API
# -------------------------

func arrange(cards: Array[CardView]) -> void:
	var active_cards : Array[CardView] = []
	
	for c in cards: active_cards.append(c)
	
	var total := active_cards.size()
	if total == 0: return
	
	for i in range(total):
		var card := active_cards[i]
		if not card: return
		
		var ratio := _get_safe_ratio(i, total - 1)
		var final_card_width : float = (min(card.size.x * total, max_arrange_width) - card.size.x) / 2
		
		var final_position := Vector2(curve_x.sample(ratio) * final_card_width, -curve_y.sample(ratio) * mult_y)
		var final_rotation := curve_rot.sample(ratio) * mult_rot
		
		var tween = card.animate("layout").set_parallel()
		
		if not card.drag_component.dragging: 
			tween.tween_property(card, "position", final_position, 1)
 			tween.tween_property(card, "scale", Vector2.ONE, 1)
		tween.tween_property(card, "rotation", final_rotation, 1)

func arrange_new(cards: Array[CardView], new_cards: Array[CardView]) -> Signal:
	var old_cards : Array[CardView]
	
	for card in cards: 
		if not new_cards.has(card): old_cards.append(card)
		else: old_cards.append(null)
	
	arrange(old_cards)
	
	var total_new := new_cards.size()
	var tweens : Array[Tween] = []
	
	for i in range(total_new):
		var card = new_cards[i]
		
		var ratio := _get_safe_ratio(i, total_new - 1)
		var final_card_width : float = (min(card.size.x * total_new, max_arrange_width) - card.size.x) / 2

		var final_rotation := curve_x.sample(ratio) * mult_rot
		var final_position := Vector2(curve_x.sample(ratio) * final_card_width, -curve_y.sample(ratio) * mult_y - 70)
		
		var tween = card.animate("layout", Tween.EASE_OUT, Tween.TRANS_EXPO).set_parallel()
		tweens.append(tween)
		
		await tween.tween_property(card, "scale", Vector2(1.0, 1.0), 0.75)
		tween.tween_property(card, "rotation", final_rotation, 0.75)
		tween.tween_property(card, "position", final_position, 0.75)
		await card.animate_flip()
	
	await get_tree().create_timer(0.75).timeout
	emit_signal("arrange_ended")
	return arrange_ended

# -------------------------
# Internal
# -------------------------

func _get_safe_ratio(value: float, of: float) -> float:
	return value / of if of > 1 else 0.5
