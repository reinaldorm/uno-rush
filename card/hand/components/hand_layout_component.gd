class_name HandLayoutComponent
extends Node

@export var curve_x : Curve
@export var curve_y : Curve
@export var curve_rot : Curve

@export var mult_x : float = 120
@export var mult_y : float = 25
@export var mult_rot : float = 0.25

@export var max_arrange_width := 200.0
@export var max_arrange_gap := 20.0

func arrange(cards: Array[CardView]) -> void:
	var active_cards : Array[CardView] = []
	
	for c in cards: 
		if not c.drag_component.dragging: active_cards.append(c)
	
	var total := active_cards.size()
	if total == 0: return
	
	## Loop starts
	for i in range(total):
		var card := active_cards[i]
		
		var ratio := 0.5 if total == 1 else float(i) / float(total - 1)
		
		var x : float = curve_x.sample(ratio) * (max_arrange_width / 2)
		print(x)
		
		#print("[ " + str(x) + " ][ " + str(final_x) + " ]")
		
		#var x : float = width * i
		
		#var final_position := Vector2(
			#curve_x.sample(ratio) * max_arrange_width,
			#-curve_y.sample(ratio) * mult_y
		#)
		
		var final_position := Vector2(
			x,
			-curve_y.sample(ratio) * mult_y
		)
		
		var final_rotation := curve_rot.sample(ratio) * mult_rot
		
		card.animate_to(final_position, final_rotation)
