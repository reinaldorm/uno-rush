extends Node
class_name GameManager

signal cards_played(card: Array[CardData])
signal cards_drawn(card: Array[CardData])
signal play_denied(card: Array[CardData])

@export var client_controller : ClientController

@export var _view_scene : PackedScene
@export var _turn_manager : TurnManager
@export var _hue_manager : HueManager
@export var _discard_pile : DiscardPile
@export var _draw_pile : DrawPile
@export var _hud : HUD

@export var _client_hand : Hand
@export var _hands : Array[Hand]
var _hands_mapped : Dictionary[int, Hand] = {}

var _last_snapshot : Dictionary = {}

# -------------------------
# Internal ################
# -------------------------

# Game Starters -----------------------------------------------------------

func _start(snapshot: Dictionary) -> void:
	var top_card := CardData.to_data(snapshot["top_card"])
	var client_id := multiplayer.multiplayer_peer.get_unique_id()

	_create_player_hand(client_id, snapshot.player.hand)
	_hud.update_player_hand(client_id == snapshot.current_player)

	for i in range(snapshot.players.size()):
		var opponent : Dictionary = snapshot.players[i]

		_create_opponent_hand(opponent.id, opponent.hand_count, i)
		_hud.set_opponent_box(opponent.id, i, opponent.hand_count, snapshot.current_player == opponent.id)

	for hand in [_client_hand] + _hands: await hand.start()

	await _discard_pile.start(top_card)
	# await _turn_manager.start(snapshot.current_player)

func _ready() -> void:
	client_controller.on_cards_played.connect(_on_cards_played)
	client_controller.on_cards_drawn.connect(_on_cards_drawn)
	client_controller.on_turn_skipped.connect(_on_turn_skipped)
	client_controller.on_game_started.connect(_on_game_started)

func _create_player_hand(id: int, hand: Array[Dictionary]) -> void:
	var cards : Array[CardData] = CardData.array_to_data(hand)
	var views : Array[CardView] = []

	for card in cards:
		var view : CardView = _view_scene.instantiate()
		view.setup(card, false)
		views.append(view)

	_client_hand.setup(id, views)

func _create_opponent_hand(id: int, hand_count: int, idx: int) -> void:
	var cards := _create_placeholder_cards(hand_count)
	var views : Array[CardView] = []

	for card in cards:
		var view : CardView = _view_scene.instantiate()
		view.setup(card, true)
		views.append(view)

	_hands[idx].setup(id, views)
	_hands_mapped[id] = _hands[idx]

# Helpers -----------------------------------------------------------------

func _create_placeholder_cards(amount: int) -> Array[CardData]:
	var cards : Array[CardData] = []

	for i in range(amount):
		cards.append(CardData.create_numbered(CardData.Hue.RED, 0))

	return cards

# Play Dispatchers --------------------------------------------------------

func _play_from_client(cards: Array[CardData]) -> void:
	var played_cards : Array[CardView] = []

	for card in cards:
		var view : CardView = _client_hand.withdraw_card(card)
		played_cards.append(view)

	_discard_pile.play(played_cards)

func _play_from_opponent(opponent_id: int, cards: Array[CardData]) -> void:
	var card_views : Array[CardView] = []
	var opponent_hand : Hand

	for hand in _hands:
		if hand.player_id == opponent_id:
			opponent_hand = hand
			break

	for card in cards:
		var view : CardView = opponent_hand.withdraw_card()
		view.setup(card, false)
		card_views.append(view)

	_discard_pile.play(card_views)

# Draw Dispatchers --------------------------------------------------------

func _add_cards_to_client_hand(cards: Array[CardData]) -> void:
	var views : Array[CardView] = []

	for card in cards:
		var view : CardView = _view_scene.instantiate()
		view.setup(card, false)
		views.append(view)

	_client_hand.add_cards(views)

func _add_cards_to_opponent_hand(opponent_id: int, draw_count: int) -> void:
	var opponent_hand : Hand
	var cards : Array[CardData] = _create_placeholder_cards(draw_count)
	var cards_to_draw : Array[CardView] = []

	for hand in _hands:
		if hand.player_id == opponent_id:
			opponent_hand = hand
			break

	for card in cards:
		var view : CardView = _view_scene.instantiate()
		view.setup(card, true)
		cards_to_draw.append(view)

	opponent_hand.add_cards(cards_to_draw)

# UI Snapshot Sync  -------------------------------------------------------

func _sync_game_snapshot(snapshot: Dictionary) -> void:
	if snapshot.is_empty(): return
	_last_snapshot = snapshot

	# Update UI (Hand counts, turn labels, etc.)
	var current_player_id : int = snapshot.get("current_player", -1)
	_hud.update_player_hand(multiplayer.get_unique_id() == current_player_id)

	if not snapshot.has("players"):
		return

	for player in snapshot.players:
		if player.id == multiplayer.get_unique_id():
			continue
		if _hands_mapped.has(player.id):
			_hud.update_opponent(player.id, player.hand_count, player.id == current_player_id)

# -------------------------
# Handlers ################
# -------------------------

# Network Handlers --------------------------------------------------------

func _on_cards_played(player_id: int, cards: Array[CardData], snapshot: Dictionary) -> void:
	print("GameManager: _on_cards_played: ", player_id)

	if player_id == multiplayer.get_unique_id():
		_play_from_client(cards)
	else:
		_play_from_opponent(player_id, cards)

	_sync_game_snapshot(snapshot)

func _on_cards_drawn(result: Dictionary) -> void:
	print("GameManager: Cards drawn from network")
	if result.success and result.player == multiplayer.get_unique_id() and result.has("cards"):
		_add_cards_to_client_hand(CardData.array_to_data(result.cards))
	elif result.success and result.player != multiplayer.get_unique_id() and result.has("draw_count"):
		_add_cards_to_opponent_hand(result.player, result.get("draw_count", 0))
		print("Enemy drew cards")

	_sync_game_snapshot(result.get("game", {}))

func _on_turn_skipped(result: Dictionary) -> void:
	if not result.success:
		print("GameManager: Turn Skip Failed")
		return

	_sync_game_snapshot(result.get("game", {}))

	var current_player_hand : Hand

	if multiplayer.get_unique_id() == result.current:
		current_player_hand = _client_hand
	else:
		current_player_hand = _hands_mapped[result.current]

	_turn_manager.update_turn(current_player_hand, result.game.direction, result.skips, result.reverses)

func _on_game_started(snapshot: Dictionary) -> void:
	_start(snapshot)

# Discard Pile Handlers ---------------------------------------------------

func _on_play_requested() -> void:
	var views = _client_hand.selection_component.selected_cards

	## Game Manager handles trivial logic validation so server doesn't need to.
	if views.is_empty(): return

	var cards : Array[CardData] = []

	for view in views:
		cards.append(view.data)

	client_controller.request_play(cards)

# Draw Pile Handlers ------------------------------------------------------

func _on_draw_requested() -> void:
	print("GameManager: Client requested draw")
	client_controller.request_draw()

# Hand Pile Handlers ------------------------------------------------------

func _on_selection_changed() -> void:
	print("GameManager: Selection changed")

# HUD Actions Handlers ----------------------------------------------------

func _on_skip_requested() -> void:
	client_controller.request_skip()
