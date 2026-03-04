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
func request_action(action: ActionType, payload: Dictionary = null) -> void:
	if not multiplayer.is_server(): return
	var sender_id := multiplayer.get_remote_sender_id()
	var result : Dictionary

	match action:
		ActionType.PLAY:
			result = _game.play(sender_id, payload.cards)
		ActionType.DRAW:
			result = _game.draw(sender_id)
		ActionType.SKIP:
			result = _game.skip(sender_id)
#       Waiting Implementation 
#		ActionType.UNO: 
#			result = _game.uno(sender_id, payload.cards)

	print("ServerController: Result: ", result)
	client_controller._on_reponse.rpc(result)

@rpc("any_peer", "call_local" ,"reliable")
func request_play_cards(cards_serial: Array[Dictionary]) -> void:
	if not multiplayer.is_server(): return
	var sender_id := multiplayer.get_remote_sender_id()

	var cards : Array[CardData] = CardData.array_to_data(cards_serial)
	var result = _game.play_cards(sender_id, cards)

	print("ServerController: Result: ", result)
	client_controller._on_cards_played.rpc(result)

@rpc("any_peer", "call_local")
func request_draw_cards() -> void:
	if not multiplayer.is_server(): return
	var sender_id := multiplayer.get_remote_sender_id()

	var result := _game.draw_cards(sender_id)

	client_controller._on_turn_skipped.rpc(result)

@rpc("any_peer", "call_local")
func request_skip_turn() -> void:
	if not multiplayer.is_server(): return
	var sender_id := multiplayer.get_remote_sender_id()

	var result := _game.skip_turn(sender_id)

	client_controller._on_turn_skipped.rpc(result)

# -------------------------
# Handlers
# -------------------------

func _get_client_id() -> int:
	return multiplayer.multiplayer_peer.get_unique_id()
