extends Node
class_name GameManager

signal cards_played(card: Array[CardData])
signal play_denied(card: Array[CardData])
signal cards_drawn(card: Array[CardData])
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

func _can_combo(starter: CardData, next_card: CardData) -> bool:
	if next_card.hue == CardData.Hue.WILD:
		if next_card.effect == starter.effect:
			return true
		else:
			return false

	if next_card.number >= 0:
		if next_card.number == starter.number:
			return true
		else:
			return false

	if next_card.effect == starter.effect:
		return true
	else:
		return false

func _get_last_played() -> CardData:
	return _discard_pile[_discard_pile.size() - 1]

# -------------------------
# Handlers
# -------------------------

# -------------------------
# Discard Pile

func _on_discard_pile_play_requested(cards: Array[CardData]) -> void:
	var can_play := _can_play(cards[0])
	var last_card := _get_last_played()
	var first_card := cards[0]

	if can_play:
		# let the pile know the play has been approved so it can commit the
		# visual transition and clear its queued cards
		_discard_pile.append_array(cards)

		print("GameManager: Waiting on discard_pile animation to end...")
		await _discard_pile_node.confirm_play()
		print("GameManager: Animation ended, following through...")

		## Update game current HUE
		if first_card.hue == CardData.Hue.WILD:
			await _hue_manager.prompt_hue_selection()
		else:
			_hue_manager.set_hue(last_card.hue)

		## Check for any effect and apply
		if first_card.effect != CardData.Effect.NULL:
			if first_card.effect == CardData.Effect.DRAW:
				for card in cards: _draw_stack += card.effect_parameter
			if first_card.effect == CardData.Effect.REVERSE:
				_turn_manager.set_reverses(cards.size())
			if first_card.effect == CardData.Effect.SKIP:
				_turn_manager.set_skips(cards.size())

		await _turn_manager.advance_turn()

		emit_signal("cards_played", cards)
		print("GameManager: Play routine ended successfully.")
	else:
		_discard_pile_node.reject_play()
		emit_signal("play_denied", cards)
		print("GameManager: Play routine ended unsuccessfully.")

# -------------------------
# Draw Pile

func _on_draw_pile_draw_requested() -> void:
	var drawn_cards : Array[CardData]

	if _draw_stack:
		for i in range(_draw_stack): drawn_cards.append(_draw_pile.pop_back())
	else:
		drawn_cards.append(_draw_pile.pop_back())

	emit_signal("cards_drawn", drawn_cards)

# -------------------------
# Hand

func _on_hand_selection_changed(card_data: Array[CardData], combo_starter) -> void:
	var available_cards : Array[CardData]


	if combo_starter and _can_play(combo_starter):
		for card in card_data:
			if card == combo_starter: available_cards.append(card)
			else:
				if _can_combo(combo_starter, card): available_cards.append(card)
	else:
		for card in card_data:
			if _can_play(card): available_cards.append(card)

	_hand.update_available_cards(available_cards)
