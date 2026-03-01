extends Node
class_name GameManager

signal cards_played(card: Array[CardData])
signal cards_drawn(card: Array[CardData])
signal play_denied(card: Array[CardData])

@export var client_controller : ClientController

@export var _turn_manager : TurnManager
@export var _hue_manager : HueManager
@export var _discard_pile_node : DiscardPile
@export var _draw_pile_node : DrawPile

@export var _hands : Array[Hand]
@export var _client_hand : Hand

@export var _card_scene : PackedScene

# -------------------------
# Public API
# -------------------------

# -------------------------
# Internal
# -------------------------

func _start(snapshot: Dictionary) -> void:
	print("GameManager: Game is supposed to be started, beggining of block.")
	###
	var top_card := CardData.to_data(snapshot["top_card"])
	discard_pile_node.setup(top_card)
	
	for player in snapshot.players:
		var id = player["id"]:

		if id == multiplayer.get_unique_id():
			_create_player_hand(id, player["hand"])
		else:
			_create_opponent_hand(id, player["hand_count"])
	
	for hand in _hands():
		await hand.start()
	
	await discard_pile_node.start()
	##
	print("GameManager: Game is supposed to be started, end of block.")




func _ready() -> void:
	client_controller.on_cards_played.connect(_on_cards_played)
	client_controller.on_cards_drawn.connect(_on_cards_drawn)
	client_controller.on_turn_skipped.connect(_on_turn_skipped)
	client_controller.on_game_started.connect(_on_game_started)

func _create_player_hand(id: int, hand: Array[Dictionary]) -> void:
	var cards : Array[CardData] = []
	var views : Array[CardView] = []

	for card_serial in hand: cards.append(CardData.to_data(card_serial))
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

	_hands[i].setup(id, views)

# -------------------------
# Handlers
# -------------------------

# Network Handlers
# Methods for handling network events

func _on_cards_played(_card_data: Array[CardData]) -> void:
	print("GameManager: Cards played from network")

func _on_cards_drawn() -> void:
	print("GameManager: Cards drawn from network")

func _on_turn_skipped() -> void:
	print("GameManager: Turn skipped from network")

func _on_game_started(snapshot: Dictionary) -> void:
	_start(snapshot)

# Discard Pile Handlers
# Methods for handling discard pile signals/requests

# Function triggered by in-game event, acknolodge by GameManager
# and sent for Server validation

func _on_play_requested() -> void:
	print("GameManager: Client requested play")

# Draw Pile Handlers
# Methods for handling draw pile signals/requests

func _on_draw_requested() -> void:
	print("GameManager: Client requested draw")

# Hand Handlers
# Methods for handling hand signals/requests

func _on_selection_changed() -> void:
	print("GameManager: Selection changed")
