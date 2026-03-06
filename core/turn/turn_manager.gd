extends Node
class_name TurnManager

signal turn_advanced(direction: int)

@export var skip_effect_scene = PackedScene
@export var reverse_effect_scene = PackedScene

@export var turn_arrow : TurnArrow
@export var direction_arrow : DirectionArrow
@export var effect_history_container : Node2D

# -------------------------
# Public Api # ------------
# -------------------------

func update_turn(current_hand: Hand, direction: int, skips: int, reverses: int):
	turn_arrow.turn(current_hand.global_position)
	direction_arrow.reverse(direction)

# -------------------------
# Internal # --------------
# -------------------------

func _process(delta: float) -> void:
	pass
