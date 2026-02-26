extends Node
class_name GameManager

signal cards_played(card: Array[CardData])
signal cards_drawn(card: Array[CardData])

signal play_denied(card: Array[CardData])
signal draw_denied()

@export var _turn_manager : TurnManager
@export var _hue_manager : HueManager
@export var _discard_pile_node : DiscardPile
@export var _draw_pile_node : DrawPile
@export var _hand : Hand

var _discard_pile : Array[CardData] = []
var _draw_pile : Array[CardData] = []
var _draw_stack := 0

const INITIAL_HAND_SIZE = 7
const DRAW_TWO_AMOUNT = 2
const DRAW_FOUR_AMOUNT = 4

enum PlayRequestType {
	PRESS,
	DROP,
	DEV
}

# -------------------------
# Public API
# -------------------------

func start() -> void:
	var deck := _create_deck()
	deck.shuffle()
	_draw_pile = deck

	var first_card = _draw_pile.pop_back()
	_hue_manager.set_hue(first_card.hue)

	_discard_pile.append(first_card)
	_discard_pile_node.start(first_card)

	var player_deck : Array[CardData] = []

	for i in range(INITIAL_HAND_SIZE): player_deck.append(_draw_pile.pop_back())

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
		var data := CardData.create_numbered(color, 0)
		new_deck.append(data)

	## Two of each numbered card from 1-9 for each color
	for color in range(4):
		for i in range(2):
			for number in range(1, 9):
				var data := CardData.create_numbered(color, number)
				new_deck.append(data)

	## Two of each special card (SKIP, REVERSE, DRAW) for each color
	for color in range(4):
		for i in range(2):
			var data_skip := CardData.create_special(color, CardData.Effect.SKIP)
			var data_reverse := CardData.create_special(color, CardData.Effect.REVERSE)
			var data_draw := CardData.create_special(color, CardData.Effect.DRAW, 2)

			new_deck.append(data_skip)
			new_deck.append(data_reverse)
			new_deck.append(data_draw)

	## Four of each special wild card (WILD, WILD FOUR) for each color
	for color in range(4):
		var data_wild := CardData.create_special(CardData.Hue.WILD, CardData.Effect.NULL)
		var data_wild_four := CardData.create_special(CardData.Hue.WILD, CardData.Effect.DRAW, 4)
		new_deck.append(data_wild)
		new_deck.append(data_wild_four)

	return new_deck

func _can_play(card: CardData) -> bool:
	## `card` will be the card which to evaluate.
	## `last_card` is necessary here should we evaluate combo legibility.

	var last_card := _discard_pile[_discard_pile.size() - 1]

	if _draw_stack:
		if card.hue == CardData.Hue.WILD and card.effect == CardData.Effect.DRAW: return true

		if _hue_manager.hue == CardData.Hue.WILD:
			if card.effect == CardData.Effect.DRAW:
				if card.hue == _hue_manager.hue: return true
		else:
			if card.effect == CardData.Effect.DRAW: return true

		return false

	if card.hue == CardData.Hue.WILD: return true
	if card.hue == _hue_manager.hue: return true
	if card.effect != CardData.Effect.NULL and card.effect == last_card.effect: return true
	if card.number >= 0 and card.number == last_card.number: return true

	return false

func _can_combo(cards: Array[CardData]) -> bool:
	var starter = cards[0]

	return cards.slice(1, cards.size()).all(func(next_card: CardData): return _can_play_with_next(starter, next_card))

func _can_play_with_next(previous: CardData, next_card: CardData) -> bool:
	if next_card.hue == CardData.Hue.WILD:
		if next_card.effect == previous.effect:
			return true
		else:
			return false

	if next_card.number >= 0:
		if next_card.number == previous.number:
			return true
		else:
			return false

	if next_card.effect == previous.effect:
		return true
	else:
		return false

func _get_last_played() -> CardData:
	return _discard_pile[_discard_pile.size() - 1]

func _apply_effects(cards_to_play: Array[CardData]) -> void:
	var first_card := cards_to_play[0]

	if first_card.effect == CardData.Effect.DRAW:
		for card in cards_to_play:
			_draw_stack += card.effect_parameter

	if first_card.effect == CardData.Effect.REVERSE:
		_turn_manager.set_reverses(cards_to_play.size())

	if first_card.effect == CardData.Effect.SKIP:
		_turn_manager.set_skips(cards_to_play.size())

func _run_play_validation() -> bool:
	# PLACEHOLDER
	# TODO: Implement play validation logic
	return true

# -------------------------
# Handlers
# -------------------------

# -------------------------
# Discard Pile
# Methods for handling discard pile signals/requests

func _on_play_requested(type: PlayRequestType) -> void:

	# FUNCTION WAY TOO BIG!!!
	# TODO: Refactor into smaller functions

	var card_views := _hand.selected_cards
	var cards_to_play : Array[CardData] = []

	for card in card_views: cards_to_play.append(card.data)

	if cards_to_play.size() == 0:
		print("GameManager: No cards selected for play")
		return

	var can_play : bool = false

	if card_views.size() == 1:
		can_play = _can_play(cards_to_play[0])
	else:
		var can_play_first = _can_play(cards_to_play[0])

		if can_play_first: can_play = _can_combo(cards_to_play)

	if type == PlayRequestType.PRESS:
		print("GameManager: Play requested via press")
	elif type == PlayRequestType.DROP:
		print("GameManager: Play requested via drop")


	var first_card = cards_to_play[0]

	if can_play:
		_discard_pile.append_array(cards_to_play)
		# let the pile know the play has been approved so it can commit the
		# visual transition and clear its queued cards
		var last_card := _get_last_played()

		print("GameManager: Waiting on discard_pile animation to end...")
		await _discard_pile_node.confirm_play(card_views)
		print("GameManager: Animation ended, following through...")

		## Update game current HUE
		if first_card.hue == CardData.Hue.WILD:
			print("GameManager: Wild card! prompting hue selection...")
			await _hue_manager.prompt_hue_selection()
		else:
			_hue_manager.set_hue(last_card.hue)

		if first_card.effect != CardData.Effect.NULL:
			_apply_effects(cards_to_play)

		await _turn_manager.advance_turn()

		emit_signal("cards_played", cards_to_play)
		print("GameManager: Play routine ended successfully.")
	else:
		_discard_pile_node.reject_play()
		emit_signal("play_denied", cards_to_play)
		print("GameManager: Play routine ended unsuccessfully.")

# -------------------------
# Draw Pile
# Methods for handling draw pile signals/requests

func _on_draw_requested() -> void:

	## TODO
	## Waiting Turn implementation logic
	## Function currently accepts any request for drawing new cards as seen below.

	var drawn_cards : Array[CardData]

	if _draw_stack:
		for i in range(_draw_stack): drawn_cards.append(_draw_pile.pop_back())
	else:
		drawn_cards.append(_draw_pile.pop_back())

	emit_signal("cards_drawn", drawn_cards)

# -------------------------
# Hand
# Methods for handling hand signals/requests

func _on_selection_changed(cards: Array[CardData], has_selection: bool) -> void:
	var available_cards : Array[CardData] = []

	if has_selection:
		if _can_combo(cards): available_cards.append_array(cards)
	else:
		for card in cards:
			if _can_play(card): available_cards.append(card)

	print("GameManager: Selection changed")
	_hand.update_available_cards(available_cards)
