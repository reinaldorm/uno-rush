extends Node
class_name ServerController

@export var client_controller : ClientController

var _game : GameLogic

enum ActionType {
	PLAY,
	DRAW,
	SKIP,
	UNO
}

# -------------------------
# Internal
# -------------------------

func _ready() -> void:
	if not multiplayer.is_server(): return
	print("Multiplayer peers: ", multiplayer.get_peers())

	_game = GameLogic.new()
	# Add the server player
	_game.add_player(multiplayer.multiplayer_peer.get_unique_id())

	for peer_id in multiplayer.get_peers():
		_game.add_player(peer_id)

	_game.start()

	for player_id in _game.players.keys():
		var peer_snapshot := _game.create_player_snapshot(player_id)

		client_controller.rpc_id(player_id, "_on_game_started", peer_snapshot)

# -------------------------
# RPC Methods
# -------------------------

@rpc("any_peer", "call_local" ,"reliable")
func request_action(action: ActionType, payload: Dictionary = {}) -> void:
	if not multiplayer.is_server(): return
	var sender_id := multiplayer.get_remote_sender_id()
	var result : Dictionary

	match action:
		ActionType.PLAY:
			result = _game.play(sender_id, payload.cards)
			result["game"] = _game.create_game_snapshot()
			client_controller._on_cards_played.rpc(result)
		ActionType.DRAW:
			result = _game.draw(sender_id)
			result["game"] = _game.create_game_snapshot()

			if result.success:
				for player_id in _game.players.keys():
					if player_id == sender_id:
						client_controller.rpc_id(player_id, "_on_cards_drawn", result)
					else:
						client_controller.rpc_id(player_id, "_on_cards_drawn", {
							"success" = true,
							"player" = sender_id,
							"draw_count" = result.get("draw_count", 0),
							"game" = result["game"]
						})
			else:
				client_controller.rpc_id(sender_id, "_on_cards_drawn", result)
		ActionType.SKIP:
			result = _game.skip(sender_id)
			result["game"] = _game.create_game_snapshot()
			client_controller._on_turn_skipped.rpc(result)
#		ActionType.UNO:
#			result = _game.uno(sender_id, payload.cards)
	print("ServerController: _on_cards_played: ", result.success)



# -------------------------
# Handlers
# -------------------------

func _get_client_id() -> int:
	return multiplayer.multiplayer_peer.get_unique_id()
