extends Node
class_name GameManager

signal cards_played(card: Array[CardData])
signal cards_drawn(card: Array[CardData])

signal play_denied(card: Array[CardData])
signal draw_denied()

@export var client_controller : ClientController

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
	print("GameManager: Started")

# -------------------------
# Internal
# -------------------------

func _ready() -> void:
	client_controller.on_cards_played.connect(_on_cards_played)
	pass

# -------------------------
# Handlers
# -------------------------


# Network Handlers
# Methods for handling network events

func _on_cards_played() -> void:
	pass

# Discard Pile Handlers
# Methods for handling discard pile signals/requests

# Function triggered by in-game event, acknolodge by GameManager
# and sent for Server validation
#
func _on_play_requested() -> void:
	var cards : Array[CardData] = []

	for view in _hand.selected_cards: cards.append(view.data)

	if not cards.size(): _discard_pile_node.deny_play()

	client_controller.request_play_cards(cards)

# Draw Pile Handlers
# Methods for handling draw pile signals/requests

func _on_draw_requested() -> void:
	client_controller.request_draw_cards()

# Hand Handlers
# Methods for handling hand signals/requests

func _on_selection_changed() -> void:
	print("GameManager: Selection changed")
