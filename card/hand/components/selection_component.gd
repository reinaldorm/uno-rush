extends Node
class_name SelectionComponent

signal card_selected(card_view: CardView)

var selected_cards : Array[CardView] = []

func deselect(card_view: CardView) -> void:
	if selected_cards.has(card_view):
		selected_cards.erase(card_view)
	card_view.is_selected = false

func deselect_all() -> void:
	for card_view in selected_cards:
		if is_instance_valid(card_view):
			card_view.is_selected = false
	selected_cards.clear()

func select(card_view: CardView) -> void:
	if selected_cards.has(card_view):
		deselect(card_view)

	else:
		selected_cards.append(card_view)
		card_view.is_selected = true

	emit_signal("card_selected", card_view)
