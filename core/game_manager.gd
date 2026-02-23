extends Node
class_name GameManager

signal cards_played(card: Array[CardData])
signal play_denied(card: Array[CardData])
signal cards_drawn(card: Array[CardData])
signal drawn_denied()

@export var _turn_manager : TurnManager
@export var _hue_manager : HueManager
@export var _discard_pile_node : DiscardPile
@export var _draw_pile_node : DrawPile
@export var _hand : Hand

var _discard_pile : Array[CardData] = []
var _draw_pile : Array[CardData] = []
var _payload := 0

# -------------------------
# Public API
# -------------------------

func start() -> void:
	var deck = _create_deck()
	deck.shuffle()
	_draw_pile = deck
	
	var first_card = _draw_pile.pop_back()
	
	_discard_pile.append(first_card)
	_discard_pile_node.start(first_card)
	
	var player_deck : Array[CardData] = []
	
	for i in range(2):
		player_deck.append(draw_pile.pop_back())
	
	_hand.start(player_deck)

# -------------------------
# Internal
# -------------------------

func _ready() -> void:
	start()

func _create_deck() -> Array[CardData]:
	var new_deck : Array[CardData]
	
	## One 0 card for each color
	for color in range(4):
		var data = CardData.create_numbered(color, 0)
		new_deck.append(data)
	
	## Two of each numbered card from 1-9 for each color
	for color in range(4):
		for i in range(2):
			for number in range(1, 9):
				var data = CardData.create_numbered(color, number)
				new_deck.append(data)
	
	## Two of each special card (SKIP, REVERSE, DRAW) for each color
	for color in range(4):
		for i in range(2):
			var data_skip = CardData.create_special(color, CardData.Effect.SKIP)
			var data_reverse = CardData.create_special(color, CardData.Effect.REVERSE)
			var data_draw = CardData.create_special(color, CardData.Effect.DRAW, 2)
			new_deck.append(data_skip)
			new_deck.append(data_reverse)
			new_deck.append(data_draw)

	## Four of each special wild card (WILD, WILD FOUR) for each color
	for color in range(4):
		var data_wild = CardData.create_special(CardData.Hue.WILD, CardData.Effect.NULL)
		var data_wild_four = CardData.create_special(CardData.Hue.WILD, CardData.Effect.DRAW, 4)
		new_deck.append(data_wild)
		new_deck.append(data_wild_four)
	
	return new_deck

func _request_play_availability(card: CardData) -> bool:
	## `card` will be the card which to evaluate.
	## `last_card` is necessary here should we evaluate combo legibility.

	var last_card = _discard_pile[_discard_pile.size() - 1]

	if _payload:
		if card.hue == CardData.Hue.WILD and card.effect == CardData.Effect.DRAW return true

		if last_card.hue == CardData.Hue.WILD:
			if card.effect == CardData.Effect.DRAW:
				if card.hue == hue_manager.hue: return true
		else: 
			if card.effect == CardData.Effect.DRAW: return true
		
		return false

	if card.hue == CardData.Hue.WILD: return true
	if card.hue == last_card.hue: return true
	if card.effect == last_card.effect: return true
	if card.number == last_card.number: return true

	return false

# -------------------------
# Handlers
# -------------------------

func _on_discard_pile_play_requested(cards: Array[CardData]) -> void:
	var request_response := _request_play_availability(cards[0])
	
	if request_response:
		emit_signal("cards_played", cards)
		discard_pile_node.accept_play_request()
		discard_pile.append_array(cards)
	else:
		emit_signal("play_denied", cards)
		discard_pile_node.deny_play_request()

func _on_draw_pile_draw_requested() -> void:
	var drawn_cards : Array[CardData]
	
	for i in range(2): drawn_cards.append(_draw_pile.pop_back())
	#draw_pile_node.draw_cards(drawn_cards)
	
	emit_signal("cards_drawn", drawn_cards)
