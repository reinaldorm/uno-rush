extends Node
class_name SelectionComponent

signal card_selected(card_view: CardView)

var selected_cards : Array[CardView] = []

func select(card_view: CardView) -> void:
	if selected_cards.has(card_view):
		selected_cards.erase(card_view)
		card_view.is_selected = false

		for i in range(selected_cards.size()):
			var card := selected_cards[i]
			card.is_selected = true

	else:
		selected_cards.append(card_view)
		card_view.is_selected = true

	emit_signal("card_selected", card_view)
