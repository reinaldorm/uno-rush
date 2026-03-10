extends Node
class_name ClientController

@export var server_controller : ServerController

var client_id : int = 0 : get = _get_client_id

signal on_cards_played(player_id: int, cards: Array[CardData], game_snapshot: Dictionary)
signal on_play_failed()

signal on_cards_drew(result: Dictionary)
signal on_drew_failed()

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
	if result.success:
		result.payload.cards = CardData.array_to_data(result.payload.cards)

		var is_client : bool = result.payload.player_id == multiplayer.get_unique_id()
		var snapshot : Dictionary = result.snapshot
		var payload = result.payload

		emit_signal("on_cards_played", is_client, payload, snapshot)
	else:
		emit_signal("on_play_failed")

@rpc("authority", "reliable", "call_local")
func _on_cards_drew(result: Dictionary) -> void:
	if result.success:
		var is_client : bool = result.payload.player_id == multiplayer.get_unique_id()

		if is_client: 
			result.payload.cards = CardData.array_to_data(result.payload.cards)

		var snapshot : Dictionary = result.snapshot
		var payload = result.payload

		emit_signal("on_cards_drew", is_client, payload, snapshot)
	else:
		emit_signal("on_drew_failed")

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
	return multiplayer.get_unique_id()
