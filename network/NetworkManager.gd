extends Node

signal server_started
signal connected_to_server
signal connection_failed
signal player_connected(id)
signal player_disconnected(id)

const DEFAULT_PORT := 8910
var is_host := false

func host_game(port := DEFAULT_PORT, max_players := 4):
    var peer = ENetMultiplayerPeer.new()
    var result = peer.create_server(port, max_players)

    if result != OK:
        push_error("Failed to start server")
        return

    multiplayer.multiplayer_peer = peer
    is_host = true

    print("Success")
    multiplayer.peer_connected.connect(_on_peer_connected)
    multiplayer.peer_disconnected.connect(_on_peer_disconnected)

    emit_signal("server_started")

func join_game(address: String, port := DEFAULT_PORT):
    var peer = ENetMultiplayerPeer.new()
    var result = peer.create_client(address, port)

    if result != OK:
        emit_signal("connection_failed")
        return

    multiplayer.multiplayer_peer = peer
    is_host = false

    print("Success")
    multiplayer.connected_to_server.connect(_on_connected)
    multiplayer.connection_failed.connect(_on_connection_failed)
    multiplayer.server_disconnected.connect(_on_server_disconnected)

func _on_connected():
    emit_signal("connected_to_server")

func _on_connection_failed():
    emit_signal("connection_failed")

func _on_server_disconnected():
    print("Server disconnected")
    multiplayer.multiplayer_peer = null

func _on_peer_connected(id):
    emit_signal("player_connected", id)

func _on_peer_disconnected(id):
    emit_signal("player_disconnected", id)
