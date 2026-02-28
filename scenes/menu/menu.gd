extends Control
class_name Menu

@onready var lobby_scene = preload("res://scenes/lobby/lobby.tscn")

# -------------------------
# Internal
# -------------------------

func _ready() -> void:
	NetworkManager.server_started.connect(_on_server_started)
	NetworkManager.connected_to_server.connect(_on_server_connected)

# -------------------------
# Handlers
# -------------------------

func _on_host_pressed() -> void:
	NetworkManager.host_game()

	await NetworkManager.server_started

	get_tree().change_scene_to_packed(lobby_scene)

func _on_join_pressed() -> void:
	NetworkManager.join_game("192.168.237.77", 8910)

func _on_options_pressed() -> void:
	print("Menu: Options not implemented yet!")

func _on_server_started() -> void:
	print("Menu: Server started.")
	get_tree().change_scene_to_packed(lobby_scene)

func _on_server_connected() -> void:
	print("Menu: Server connected.")
	get_tree().change_scene_to_packed(lobby_scene)
