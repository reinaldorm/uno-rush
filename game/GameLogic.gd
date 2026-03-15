extends Node
class_name GameLogic

var players : Dictionary[int, Dictionary] = {}

var turn_order := []
var current_turn := 0
var direction := 1
var reverses := 0
var skips := 0

var discard_pile : Array[CardData] = []
var draw_pile : Array[CardData] = []
var draw_stack := 0

var ongoing = false
var play_lock = false
var draw_lock = false
var play_stack : Array[CardData] = []

const fail_reason := {
	inv_turn = "Invalid turn, not sender's turn.",
	inv_play = "Invalid play, cards not playable.",
	locked = "Action locked, (seeing this should be a bug).",
}

# -------------------------
# Public API
# -------------------------

func start() -> void:
	draw_pile = _create_deck()

	draw_pile.shuffle()

	discard_pile.append(CardData.create_numbered(CardData.Hue.RED, 0))

	for player in players.values():
		var hand := _draw_from_pile(7)
		player["hand"].append_array(hand)

	ongoing = true

func draw(player_id: int) -> Dictionary:
	if player_id != _current_player(): return _generate_fail_response(player_id, fail_reason.inv_turn)
	if draw_lock: return _generate_fail_response(player_id, fail_reason.locked)

	var player := players[player_id]
	var cards : Array[CardData] = []
	var response : Dictionary = {}

	if draw_stack:
		cards = _draw_from_pile(draw_stack)

		response = _generate_draw_response(player_id, cards)
		var turn_info = _advance_turn()

		response.payload["turn_info"] = turn_info
		draw_stack = 0

	else:
		draw_lock = true
		cards = _draw_from_pile(1)
		response  = _generate_draw_response(player_id, cards)

	player.hand.append_array(cards)
	return response

func play(player_id: int, cards_serial: Array[Dictionary]) -> Dictionary:
	if player_id != _current_player(): return _generate_fail_response(player_id, fail_reason.inv_turn)
	if play_lock: return _generate_fail_response(player_id, "DEPRECATED: Play lock, player already played. :DEPRECATED")

	var cards := CardData.array_to_data(cards_serial)
	var player = players[player_id]

	var ok = _validate_play(_last_card(), cards, draw_stack)

	if ok:
		if cards[0].hue == CardData.Hue.WILD:
			play_stack = cards.duplicate()
			return { "success" = true, "awaiting_selection" = true }
		else:
			_add_to_pile(cards)
			_apply_effects(cards)
			_remove_from_hand(player, cards)

			var turn_info = _advance_turn()

			return _generate_play_response(player_id, cards_serial, turn_info)
	else:
		return _generate_fail_response(player_id, fail_reason.inv_play)

func skip(player_id: int) -> Dictionary:
	if player_id != _current_player(): return _generate_fail_response(player_id, fail_reason.inv_turn)

	var turn_info = _advance_turn()

	return _generate_skip_response(player_id, turn_info)

func select_hue(player_id: int, hue: int) -> Dictionary:
	if player_id != _current_player(): return _generate_fail_response(player_id, fail_reason.inv_turn)
	
	var player = players[player_id]
	
	for card in play_stack: 
		card.faceless = true
		card.hue = hue as CardData.Hue

	_add_to_pile(play_stack)
	_apply_effects(play_stack)
	_remove_from_hand(player, play_stack)

	var turn_info = _advance_turn()
	var response = _generate_play_response(player_id, CardData.array_to_serial(play_stack), turn_info)
	
	play_stack = []

	return response


func add_player(player: Dictionary) -> Dictionary:
	print("GameLogic: Tried to add player with ID and Name: ", player.id, player.name)
	players[player.id] = { "hand" = [], "id" = player.id, "name" = player.name }
	turn_order.append(player.id)
	return players[player.id]

func create_player_snapshot(player_id: int) -> Dictionary:
	var player_hand_serial : Array[Dictionary] = CardData.array_to_serial(players[player_id].hand)
	var player_snapshot : Dictionary = { "id" = players[player_id]["id"], "hand" = player_hand_serial }
	var snapshot := create_game_snapshot(player_id)
	snapshot["player"] = player_snapshot
	return snapshot

func create_game_snapshot(exclude_player_id: int = -1) -> Dictionary:
	var top_card_serial : Dictionary = {}

	if not discard_pile.is_empty():
		top_card_serial = CardData.to_serial(discard_pile[discard_pile.size() - 1])

	return {
		"ongoing" = ongoing,
		"current_player" = _current_player(),
		"direction" = direction,
		"draw_stack" = draw_stack,
		"top_card" = top_card_serial,
		"players" = _create_players_snapshot(exclude_player_id),
		"play_lock" = play_lock,
		"draw_lock" = draw_lock
	}

# -------------------------
# Internal Game Logic
# -------------------------

# Code will run on server but may be run on client for
# early play validation for visual feedback since it its lightweigh
# and deterministic

func _advance_turn() -> Dictionary:
	play_lock = false
	draw_lock = false

	var skip_count := skips
	var reverse_count := reverses

	_next_turn()

	return { "skips" = skip_count, "reverses" = reverse_count }

func _validate_play(top_card: CardData, cards: Array[CardData], stack: int) -> bool:
	# No cards, returns false.
	if not cards.size(): return false

	# If trying to play more than 1 card, we should first evaluates whether the
	# combo is valid before rule logic.
	if cards.size() > 1:
		if not GameLogic.can_combo(cards): return false

	# If `stack > 0`, only wild fours and same-color draws can be played
	# since it represents a special a strict condition, we check it first.
	if stack:
		if GameLogic.can_stack(top_card, cards[0]): return true
		else: return false

	# If `stack` is 0 we follow we standard procedure
	# Since we know the combo is valid we can only verify first card
	else:
		if GameLogic.can_play(top_card, cards[0]): return true
		else: return false

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

func _apply_effects(cards: Array[CardData]) -> void:
	if cards[0].effect == CardData.Effect.DRAW:
		draw_stack += cards.size() * cards[0].effect_parameter

	if cards[0].effect == CardData.Effect.REVERSE:
		reverses += cards.size()

	if cards[0].effect == CardData.Effect.SKIP:
		skips += cards.size()

static func can_play(top_card: CardData, card: CardData) -> bool:
	if card.hue == CardData.Hue.WILD: return true
	if card.hue == top_card.hue: return true
	if card.effect != CardData.Effect.NULL and card.effect == top_card.effect: return true
	if card.number >= 0 and card.number == top_card.number: return true

	return false

static func can_combo(cards: Array[CardData]) -> bool:
	var starter = cards[0]

	return cards.slice(1, cards.size()).all(func(next_card: CardData): return GameLogic.can_play_with_next(starter, next_card))

static func can_stack(top_card: CardData, card: CardData) -> bool:
	if card.hue == CardData.Hue.WILD and card.effect == CardData.Effect.DRAW: return true

	if top_card.hue == CardData.Hue.WILD:
		if card.effect == CardData.Effect.DRAW:
			if card.hue == top_card.hue: return true
	else:
		if card.effect == CardData.Effect.DRAW: return true

	return false

static func can_play_with_next(previous: CardData, next_card: CardData) -> bool:
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

# -------------------------
# Internal Helpers
# -------------------------

func _next_turn() -> void:
	var next := current_turn

	if reverses and reverses % 2 != 0: direction = -direction
	for i in range(skips + 1):
		next = (next + direction) % players.size()
		if next < 0: next += players.size()

	skips = 0
	reverses = 0
	current_turn = next

func _current_player() -> int:
	return turn_order[current_turn]

func _create_players_snapshot(exclude_player_id: int = -1) -> Array[Dictionary]:
	var players_snapshot : Array[Dictionary] = []

	for id in turn_order:
		if id == exclude_player_id: continue
		var player = players[id]

		players_snapshot.append({
			"id" = player.id,
			"hand_count" = player.hand.size(),
			"name" = player.name
		})

	return players_snapshot

func _remove_from_hand(player: Dictionary, cards: Array[CardData]) -> void:
	player.hand = player.hand.filter(func(card): return cards.all(func(to_remove): return card.id != to_remove.id))

func _add_to_pile(cards: Array[CardData]) -> void:
	discard_pile.append_array(cards)

func _draw_from_pile(amount: int) -> Array[CardData]:
	var stack : Array[CardData] = []

	for i in range(amount): stack.append(draw_pile.pop_back())

	return stack

func _last_card() -> CardData:
	return discard_pile[discard_pile.size() - 1]

# -------------------------
# Response Helpers
# -------------------------

func _generate_play_response(player_id: int, cards: Array[Dictionary], turn_info: Dictionary) -> Dictionary:
	return { 
		"success" = true,
		"payload" = {
			"player_id" = player_id,
			"cards" = cards,
			"turn_info" = turn_info
		}
	}

func _generate_draw_response(player_id: int, cards: Array[CardData]) -> Dictionary:

	return {
		"success" = true,
		"payload" = {
			"player_id" = player_id,
			"cards" = CardData.array_to_serial(cards),
			"draw_count" = cards.size()
		}
	}

func _generate_skip_response(player_id: int, turn_info: Dictionary) -> Dictionary:

	return {
		"success" = true,
		"payload" = {
			"player_id" = player_id,
			"turn_info" = turn_info
		}
	}

func _generate_hue_selection_response(player_id: int, cards: Array[CardData], turn_info) -> Dictionary:

	return {
		"success" = true,
		"payload" = {
			"player_id" = player_id,
			"cards" = CardData.array_to_serial(cards),
			"turn_info" = turn_info
		}
	}

func _generate_fail_response(player_id: int, reason: String) -> Dictionary:
	return {
		"success": false,
		"payload": {
			"player_id": player_id,
			"reason" : reason
		}
	}