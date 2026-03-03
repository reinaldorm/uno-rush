extends Node
class_name ServerController

@export var client_controller : ClientController

var _game : GameLogic

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
func request_play_cards(cards_serial: Array[Dictionary]) -> void:
	if not multiplayer.is_server(): return
	var sender_id := multiplayer.get_remote_sender_id()

	print("ServerController: Acknowledged play request: ", sender_id, cards_serial)

	var cards : Array[CardData] = CardData.array_to_data(cards_serial)
	var result = _game.play_cards(sender_id, cards)

	if result:
		client_controller._on_cards_played.rpc(result)
	else:
		client_controller._on_play_failed.rpc_id(sender_id)

@rpc("any_peer", "call_local")
func request_draw_cards() -> void:
	pass

@rpc("any_peer", "call_local")
func request_turn_skip() -> void:
	pass

# -------------------------
# Handlers
# -------------------------

func _get_client_id() -> int:
	return multiplayer.multiplayer_peer.get_unique_id()
