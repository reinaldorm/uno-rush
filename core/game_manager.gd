extends Node
class_name GameManager

signal cards_played(card: Array[CardData])
signal cards_drawn(card: Array[CardData])
signal play_denied(card: Array[CardData])

@export var client_controller : ClientController

@export var _turn_manager : TurnManager
@export var _hue_manager : HueManager
@export var _discard_pile : DiscardPile
@export var _draw_pile : DrawPile

@export var _client_hand : Hand
@export var _hands : Array[Hand]
var _hands_mapped : Dictionary[int, Hand] = {}

@export var _view_scene : PackedScene

# -------------------------
# Public API
# -------------------------

# -------------------------
# Internal
# -------------------------

func _start(snapshot: Dictionary) -> void:

	var top_card := CardData.to_data(snapshot["top_card"])

	_create_player_hand(multiplayer.multiplayer_peer.get_unique_id(), snapshot.player.hand)

	for i in range(snapshot.players.size()):
		var player : Dictionary = snapshot.players[i]

		_create_opponent_hand(player.id, player.hand_count, i)

	for hand in [_client_hand] + _hands: await hand.start()

	_discard_pile.start(top_card)

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
	var cards : Array[CardData] = []
	var views : Array[CardView] = []

	for i in range(hand_count):
		var card_data = CardData.create_numbered(CardData.Hue.RED, 0)
		cards.append(card_data)

	for card in cards:
		var view : CardView = _view_scene.instantiate()
		view.setup(card, true)
		views.append(view)

	_hands[idx].setup(id, views)
	_hands_mapped[id] = _hands[idx]

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

# -------------------------
# Handlers
# -------------------------

# Network Handlers
# Methods for handling network events

func _on_cards_played(player_id: int, cards: Array[CardData]) -> void:
	print("GameManager: _on_cards_played: ", player_id)

	if player_id == multiplayer.get_unique_id():
		_play_from_client(cards)
	else:
		_play_from_opponent(player_id, cards)

func _on_cards_drawn() -> void:
	print("GameManager: Cards drawn from network")

func _on_turn_skipped() -> void:
	print("GameManager: Turn skipped from network")

func _on_game_started(snapshot: Dictionary) -> void:
	_start(snapshot)

# Discard Pile Handlers
# Methods for handling discard pile signals/requests
func _on_play_requested() -> void:
	var views = _client_hand.selection_component.selected_cards

	## Game Manager handles trivial logic validation so server doesn't need to.
	if views.is_empty(): return

	var cards : Array[CardData] = []

	for view in views:
		cards.append(view.data)

	client_controller.request_play(cards)

# Draw Pile Handlers
# Methods for handling draw pile signals/requests

func _on_draw_requested() -> void:
	print("GameManager: Client requested draw")

# Hand Handlers
# Methods for handling hand signals/requests

func _on_selection_changed() -> void:
	print("GameManager: Selection changed")

# Skip Turn Handlers
# Methods for handling skip turn signals/requests

func _on_skip_requested() -> void:
	client_controller.request_skip()
