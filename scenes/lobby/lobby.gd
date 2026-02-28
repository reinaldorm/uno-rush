extends Control

@export var _players_node : Control
@onready var _main_scene = preload("res://scenes/main/main.tscn")


var _random_usernames = ["assortedcow", "abandonediguana", "overratedpanda", "makeshiftboars", "derangedflamingo", "enchantingvulture", "timidelephant", "advancedpigeon", "futuristicmonkey", "smartmouse"]
var _partial_players : Array[Dictionary] = []

# -------------------------
# Internal
# -------------------------

func _ready() -> void:
	NetworkManager.player_connected.connect(_on_player_connected)

	var _id := multiplayer.multiplayer_peer.get_unique_id()

	if _id == 1: _setup_players(_id)

func _setup_players(_id: int):
	_partial_players.append({
		"id": _id,
		"name": _random_usernames[RandomNumberGenerator.new().randi() % _random_usernames.size()]
	})

	_update_players()

func _update_players():

	for idx in range(_partial_players.size()):
		var player_panel = _players_node.get_child(idx)
		var player_label : RichTextLabel = player_panel.get_node("PlayerName")
		player_label.text = _partial_players[idx]["name"]

	print("Lobby: Updated players.")

# -------------------------
# Handlers
# -------------------------

func _on_start_pressed():
	if multiplayer.multiplayer_peer.get_unique_id() != 1: return
	if _partial_players.size() < 2: return

	rpc("_on_game_started")

func _on_player_connected(peer_id: int):
	var rand_name = _random_usernames.pick_random()

	while _partial_players.any(func(player: Dictionary): return player["name"] == rand_name):
		rand_name = _random_usernames.pick_random()

	_partial_players.append({
		"id": peer_id,
		"name": rand_name
	})

	_update_players()
	rpc("_on_lobby_updated", _partial_players)

@rpc("authority", "call_remote", "reliable")
func _on_lobby_updated(player_data: Array[Dictionary]) -> void:
	_partial_players = player_data
	_update_players()

@rpc("authority", "call_local")
func _on_game_started() -> void:
	get_tree().change_scene_to_packed(_main_scene)
