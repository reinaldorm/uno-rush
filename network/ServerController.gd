extends Node
class_name ServerController

@export var client_controller : ClientController

var _game : GameLogic

enum ActionType {
	PLAY,
	DRAW,
	SKIP,
	SELECT_HUE,
	SELECT_HAND,
	UNO
}

# -------------------------
# Internal
# -------------------------

func _ready() -> void:
	if not multiplayer.is_server(): return

	_game = GameLogic.new()
	# Add the server player
	# _game.add_player(multiplayer.get_unique_id())

	for player in SessionManager.players:
		_game.add_player(player)

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

			if result.success:
				if result.get("awaiting_selection", null):
					client_controller._on_hue_selection_request.rpc_id(sender_id)
				else:
					result["snapshot"] = _game.create_game_snapshot()
					client_controller._on_cards_played.rpc(result)
			else:
				client_controller._on_cards_played.rpc_id(sender_id, result)

		ActionType.DRAW:
			result = _game.draw(sender_id)
			result["snapshot"] = _game.create_game_snapshot()

			if result.success:
				client_controller.rpc("_on_cards_drew", result)
			else:
				client_controller.rpc_id(sender_id, "_on_cards_drew", result)

		ActionType.SKIP:
			result = _game.skip(sender_id)
			result["snapshot"] = _game.create_game_snapshot()
			client_controller._on_turn_changed.rpc(result)
		
		ActionType.SELECT_HUE:
			result = _game.select_hue(sender_id, payload.hue)
			result["snapshot"] = _game.create_game_snapshot()
			client_controller._on_cards_played.rpc(result)

# -------------------------
# Handlers
# -------------------------

func _get_client_id() -> int:
	return multiplayer.multiplayer_peer.get_unique_id()
