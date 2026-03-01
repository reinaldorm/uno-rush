extends Node
class_name ServerController

@export var client_controller : ClientController

var _game : GameLogic

# -------------------------
# RPC Methods
# -------------------------

@rpc("any_peer")
func request_start() -> void:
    var sender_id := multiplayer.get_remote_sender_id()
    if sender_id != 1: return

    var ok = _game.start()

    if ok:
        client_controller._on_game_started.rpc() ## TODO: send back game information
    else:
        client_controller._on_start_failed.rpc_id(sender_id)

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
