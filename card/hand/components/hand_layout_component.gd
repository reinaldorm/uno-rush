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

func arrange(cards: Array[CardView]) -> void:
	var active_cards : Array[CardView] = []
	
	#for c in cards: if not c.drag_component.dragging: active_cards.append(c)
	for c in cards: active_cards.append(c)
	
	var total := active_cards.size()
	if total == 0: return
	
	## Loop starts
	for i in range(total):
		var card := active_cards[i]
		
		var ratio := 0.5 if total == 1 else float(i) / float(total - 1)

		var card_width := card.get_size().x
		var final_card_width := card_width * total

		if final_card_width > max_arrange_width:
			final_card_width = max_arrange_width
		
		final_card_width -= card_width
		
		var final_position := Vector2(
			curve_x.sample(ratio) * (final_card_width / 2),
			-curve_y.sample(ratio) * mult_y
		)
		
		var final_rotation := curve_rot.sample(ratio) * mult_rot
		
		var tween = card.animate("layout")
		tween.set_parallel()
		tween.set_ease(Tween.EASE_OUT)
		tween.set_trans(Tween.TRANS_ELASTIC)
		
		if not card.drag_component.dragging: tween.tween_property(card, "position", final_position, 1)
		tween.tween_property(card, "rotation", final_rotation, 1)
		
