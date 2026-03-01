extends Node
class_name GameLogic

var players : Dictionary[String, Dictionary] = {}

var turn_order := []
var current_turn := 0

var discard_pile : Array[CardData] = []
var draw_pile : Array[CardData] = []
var draw_stack := 0

# -------------------------
# Internal
# -------------------------

# Code will run on server but may be run on client for
# early play validaton for visual feedback since it its lightweigh
# and deterministic
func _can_play(card: CardData) -> bool:
	var last_card := discard_pile[discard_pile.size() - 1]

	if card.hue == CardData.Hue.WILD: return true
	if card.hue == last_card.hue: return true
	if card.effect != CardData.Effect.NULL and card.effect == last_card.effect: return true
	if card.number >= 0 and card.number == last_card.number: return true

	return false

func _can_combo(cards: Array[CardData]) -> bool:
	var starter = cards[0]

	return cards.slice(1, cards.size()).all(func(next_card: CardData): return _can_play_with_next(starter, next_card))

func _can_stack(card: CardData) -> bool:
	var last_card := discard_pile[discard_pile.size() - 1]

	if card.hue == CardData.Hue.WILD and card.effect == CardData.Effect.DRAW: return true

	if last_card.hue == CardData.Hue.WILD:
		if card.effect == CardData.Effect.DRAW:
			if card.hue == last_card.hue: return true
	else:
		if card.effect == CardData.Effect.DRAW: return true

	return false

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

func _validate_play(cards: Array[CardData]) -> bool:
	# No cards, returns false.
	if not cards.size(): return false

	# If trying to play more than 1 card, we should first evaluates whether the
	# combo is valid before rule logic.
	if cards.size() > 1:
		if not _can_combo(cards): return false

	# If `_draw_stack > 0`, only wild fours and same-color draws can be played
	# since it represents a special a strict condition, we check it first.
	if draw_stack:
		if _can_stack(cards[0]): return true
		else: return false

	# If `_draw_stack` is 0 we follow we standard procedure
	# Since we know the combo is valid we can only verify first card
	else:
		if _can_play(cards[0]): return true
		else: return false

# -------------------------
# Internal
# -------------------------

func add_player(id) -> Dictionary:
	players[id] = { "hand" = [] }
	turn_order.append(id)
	return players[id]

func current_player() -> Dictionary:
	return turn_order[current_turn]

func next_turn() -> void:
	current_turn = (current_turn + 1) % turn_order.size()

func start() -> void:
	draw_pile = _create_deck()
	discard_pile.append(CardData.create_number(CardData.Hue.RED, 0)
	for player in players.values():
		var hand := draw_from_pile(7)

func draw_from_pile(amount: int) -> Array[CardData]:
	var stack : Array[CardData] = []

	for i in range(amount): stack.append(draw_pile.pop_back))

	return stack

func draw_cards(player_id: int) -> void:
	if player_id != current_player()
	var player := players[player_id]

	player.hand.append_array(draw_stack)

func play_card(player_id, card):
	if player_id != current_player(): return false
	if card not in players[player_id].hand: return false

	players[player_id].hand.erase(card)
	next_turn()

	return true
