extends Node
class_name ClientController

@export var server_controller : ServerController

var client_id : int = 0 : get = _get_client_id

signal on_cards_played(result: Dictionary)
signal on_play_failed()

signal on_cards_drawn()

signal on_turn_skipped()

signal on_game_started(snapshot: Dictionary)

# -------------------------
# Public API
# -------------------------

func request_play(cards: Array[CardData]) -> void:
	var cards_serial : Array[Dictionary] = []

	for card in cards:
		cards_serial.append(CardData.to_serial(card))

	server_controller.request_play_cards.rpc_id(1, cards_serial)

func request_draw() -> void:
	server_controller.request_draw_cards.rpc_id(1)

func request_skip() -> void:
	server_controller.request_turn_skip.rpc_id(1)

# -------------------------
# RPC Handlers
# -------------------------

@rpc("authority", "reliable", "call_local")
func _on_cards_played(result: Dictionary) -> void:
	emit_signal("on_cards_played", result)

@rpc("authority", "reliable", "call_local")
func _on_play_failed() -> void:
	print("Play failed, player: ", multiplayer.get_unique_id())
	emit_signal("on_play_failed")

@rpc("authority", "reliable", "call_local")
func _on_cards_drawn() -> void:
	emit_signal("on_cards_drawn")

@rpc("authority", "reliable", "call_local")
func _on_turn_skipped() -> void:
	emit_signal("on_turn_skipped")

@rpc("authority", "reliable", "call_local")
func _on_game_started(snapshot: Dictionary):
	emit_signal("on_game_started", snapshot)

# -------------------------
# Handlers
# -------------------------

func _get_client_id() -> int:
	return multiplayer.multiplayer_peer.get_unique_id()
