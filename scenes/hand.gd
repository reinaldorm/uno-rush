@tool
extends Control
class_name Hand

## Arrangement values
@export var curve_x : Curve
@export var curve_y : Curve
@export var curve_rot : Curve
@export var mult_x : float = 120
@export var mult_y : float = 25
@export var mult_rot : float = 0.25

## Nodes
@export var card_scene : PackedScene
@export var selection_component: SelectionComponent

var cards : Array[Card] = []

func add_card(card: Dictionary) -> void:
	var c : Card = card_scene.instantiate()
	c.start(card)
	
	add_child(c)
	cards.append(c)
	
	c.card_down.connect(_on_card_down)
	c.card_up.connect(_on_card_up)
	c.card_pressed.connect(_on_card_pressed)
	
	c.arrange_index = cards.size() - 1

func arrange_hand() -> void:
	var cards_to_arrange : Array[Card] = cards.filter(func(card: Card): return not card.being_held)
	var total_cards : int = cards_to_arrange.size()
	
	if total_cards:
		for idx in range(total_cards):
			var card = cards_to_arrange[idx]
			var ratio = float(idx) / float(total_cards - 1);
			
			var x_sample = curve_x.sample(ratio)
			var y_sample = curve_y.sample(ratio)
			var rot_sample = curve_rot.sample(ratio)
			
			var final_position = Vector2(x_sample * mult_x, y_sample * -1 * mult_y)
			var final_rot = rot_sample * mult_rot
			
			card.tween_arange = card.create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC).set_parallel()
			card.tween_arange.tween_property(card, "position", final_position, 1)
			card.tween_arange.tween_property(card, "rotation", final_rot, 1)

## BT

## Handlers

func _on_card_down(card: Card) -> void:
	CardManager.hold_card(card)
	arrange_hand()
	
func _on_card_up(card: Card) -> void:
	CardManager.drop_card(card)
	arrange_hand()

func _on_card_pressed(card: Card) -> void:
	selection_component.select(card)
