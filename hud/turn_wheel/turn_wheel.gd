extends Control
class_name TurnWheel

var _tween : Tween

@export var _player_card : TurnCard
@export var _opponent_card : TurnCard

# -------------------------
# Public API
# -------------------------

func turn_client() -> void:
	_player_card.show_card()
	_opponent_card.hide_card()
	print("Client")

func turn_opponent() -> void:
	_player_card.hide_card()
	_opponent_card.show_card()
	print("Opponent")

# -------------------------
# Internal
# -------------------------

func _ready() -> void:
	_player_card.setup(_player_card.position)
	_opponent_card.setup(_opponent_card.position)
