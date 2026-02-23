extends Node
class_name GameManager

@export var hand : Hand
@export var draw_pile_node : DrawPile
@export var discard_pile_node : DiscardPile

var discard_pile: Array[CardData] = []
var draw_pile: Array[CardData] = []

signal cards_played(card: Array[CardData])
signal play_denied(card: Array[CardData])

signal cards_drawn(card: Array[CardData])
signal drawn_denied(card: Array[CardData])

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
	
	for i in range(2):
		player_deck.append(draw_pile.pop_back())
	
	hand.start(player_deck)

# -------------------------
# Internal
# -------------------------

func _ready() -> void:
	start()

func _create_deck() -> Array[CardData]:
	var new_deck : Array[CardData]
	
	## One 0 card for each color
	for color in range(4):
		var data = CardData.create(color, 0)
		new_deck.append(data)
	
## Two of each numbered card from 1-12 for each color
	for color in range(4):
		for i in range(2):
			for number in range(12):
				var data = CardData.create(color, number)
				new_deck.append(data)
	
	return new_deck

# -------------------------
# Handlers
# -------------------------

func _on_discard_pile_play_requested(cards: Array[CardData]) -> void:
	var last_played_card = discard_pile[discard_pile.size() - 1]
	var is_play_valid := false
	
	if cards[0].number == last_played_card.number:
		is_play_valid = true
		print("cool UPSIDE")
	elif cards[0].color == last_played_card.color:
		is_play_valid = true
		print("cool DOWNSIDE")
		
	if is_play_valid:
		emit_signal("cards_played", cards)
		discard_pile_node.accept_play_request()
		discard_pile.append_array(cards)
	else:
		emit_signal("play_denied", cards)
		discard_pile_node.deny_play_request()

func _on_draw_pile_draw_requested() -> void:
	var drawn_cards : Array[CardData]
	
	for i in range(2): drawn_cards.append(draw_pile.pop_back())
	#draw_pile_node.draw_cards(drawn_cards)
	
	emit_signal("cards_drawn", drawn_cards)
