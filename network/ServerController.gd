extends Node
class_name ServerController

@export var client_controller : ClientController

var _game : GameLogic


# -------------------------
# Internal
# -------------------------

func _ready() -> void:
    if not multiplayer.is_server: return

    _game = GameLogic.new()
    _game.start()

    for peer in multiplayer.get_peers():
        var peer_snapshot := create_player_snapshot(peer)

        client_controller.rpc_id(peer, "_on_game_started", peer_snapshot)

# -------------------------
# RPC Methods
# -------------------------



@rpc("any_peer", "reliable")
func request_play_cards(cards_serial: Array[Dictionary]) -> void:
    var sender_id := multiplayer.get_remote_sender_id()

    var cards : Array[CardData] = []
    for serial in cards_serial: cards.append(CardData.to_data(serial))

    var ok = _game.play_cards(cards)

    if ok:
        client_controller._on_cards_played.rpc() ## TODO: send back game information
    else:
        client_controller._on_play_failed.rpc_id(sender_id)

@rpc("any_peer", "reliable")
func request_draw_cards() -> void:
    pass

@rpc("any_peer", "reliable")
func request_turn_skip() -> void:
    pass

# -------------------------
# Handlers
# -------------------------

func _get_client_id() -> int:
    return multiplayer.multiplayer_peer.get_unique_id()
