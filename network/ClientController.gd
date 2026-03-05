extends Node
class_name ClientController

@export var server_controller : ServerController

var client_id : int = 0 : get = _get_client_id

signal on_cards_played(player_id: int, cards: Array[CardData], game_snapshot: Dictionary)
signal on_play_failed()

signal on_cards_drawn(result: Dictionary)

signal on_turn_skipped(result: Dictionary)

signal on_game_started(snapshot: Dictionary)

# -------------------------
# Public API
# -------------------------

func request_play(cards: Array[CardData]) -> void:
	var cards_serial : Array[Dictionary] = CardData.array_to_serial(cards)

	server_controller.request_action.rpc_id(1, ServerController.ActionType.PLAY, { "cards" = cards_serial })

func request_draw() -> void:
	server_controller.request_action.rpc_id(1, ServerController.ActionType.DRAW)

func request_skip() -> void:
	server_controller.request_action.rpc_id(1, ServerController.ActionType.SKIP)

# -------------------------
# RPC Handlers
# -------------------------

@rpc("authority", "reliable", "call_local")
func _on_cards_played(result: Dictionary) -> void:
	print("ClientController: _on_cards_played: ", result.success)

	if result.success:
		var player_id = result.player
		var cards = CardData.array_to_data(result.cards)
		var game_snapshot : Dictionary = result.get("game", {})

		emit_signal("on_cards_played", player_id, cards, game_snapshot)
	else:
		emit_signal("on_play_failed")

@rpc("authority", "reliable", "call_local")
func _on_cards_drawn(result: Dictionary) -> void:
	emit_signal("on_cards_drawn", result)

@rpc("authority", "reliable", "call_local")
func _on_turn_skipped(result: Dictionary) -> void:
	emit_signal("on_turn_skipped", result)

@rpc("authority", "reliable", "call_local")
func _on_game_started(snapshot: Dictionary):
	emit_signal("on_game_started", snapshot)

# -------------------------
# Handlers
# -------------------------

func _get_client_id() -> int:
	return multiplayer.multiplayer_peer.get_unique_id()
