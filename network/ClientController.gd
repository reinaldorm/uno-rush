extends Node
class_name ClientController

@export var server_controller : ServerController

var client_id : int = 0 : get = _get_client_id

signal on_cards_played()
signal on_cards_drawn()
signal on_cards_skip()

# -------------------------
# Public API
# -------------------------

func request_play_cards(cards: Array[CardData]) -> void:
	server_controller.request_play_cards.rpc_id(1, cards)

func request_draw_cards() -> void:
	server_controller.request_draw_cards.rpc_id(1)

func request_turn_skip() -> void:
	server_controller.request_turn_skip.rpc_id(1)

# -------------------------
# RPC Handlers
# -------------------------

@rpc("authority", "reliable", "call_local")
func _on_cards_played() -> void:
	emit_signal("_on_cards_played()")

@rpc("authority", "reliable", "call_local")
func _on_play_failed() -> void:
	emit_signal("_on_cards_played()")

@rpc("authority", "reliable", "call_local")
func _on_turn_skip() -> void:
	emit_signal("_on_cards_played()")

# -------------------------
# Handlers
# -------------------------

func _get_client_id() -> int:
	return multiplayer.multiplayer_peer.get_unique_id()
