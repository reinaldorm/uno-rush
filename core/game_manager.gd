extends Node
class_name GameManager

@export var hand : Hand
@export var draw_pile_node : DrawPile
@export var discard_pile_node : DiscardPile

var discard_pile: Array[CardData] = []
var draw_pile: Array[CardData] = []

signal cards_played(card: Array[CardView])

# -------------------------
# Public API
# -------------------------

func start() -> void:
	var deck = _create_deck()
	deck.shuffle()
	draw_pile = deck
	
	var first_card = draw_pile.pop_back()
	
	discard_pile.append(first_card)
	discard_pile_node.start(first_card)
	
	var player_deck : Array[CardData] = []
	
	for i in range(7):
		player_deck.append(draw_pile.pop_back())
	
	hand.add_cards(player_deck)

# -------------------------
# Internal
# -------------------------

func _ready() -> void:
	start()

func _create_deck() -> Array[CardData]:
	var new_deck : Array[CardData]
	
	## One 0 card for each color
	for color in CardData.COLOR.values():
		var data = CardData.create(color, 0)
		new_deck.append(data)
	
## Two of each numbered card from 1-9 for each color
	for color in CardData.COLOR.values():
		for i in range(2):
			for number in range(9):
				var data = CardData.create(color, number)
				new_deck.append(data)
	
	return new_deck

# -------------------------
# Handlers
# -------------------------

func _on_discard_pile_play_requested(card: CardView) -> void:
	var data := card.data
	var payload : Array[CardView] = [card]
	
	if data.number == discard_pile[0].number:
		discard_pile_node.accept_play_request(card)
		emit_signal("cards_played", payload)
	elif data.color == discard_pile[discard_pile.size() - 1].color:
		discard_pile_node.accept_play_request(card)
		emit_signal("cards_played", payload)
	else:
		discard_pile_node.deny_play_request(card)
