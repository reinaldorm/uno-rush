extends Node
class_name TurnManager

signal turn_advanced(direction: int)

@export var skip_effect_scene = PackedScene
@export var reverse_effect_scene = PackedScene

@export var turn_arrow : Node2D
@export var direction_arrow : Node2D
@export var effect_history_container : Node2D

# -------------------------
# Public Api # ------------
# -------------------------

func update_turn(current_hand: Hand, skips: int, reverses: int):
	pass

# -------------------------
# Internal # --------------
# -------------------------

func _move_turn_arrow() -> void:
	pass
