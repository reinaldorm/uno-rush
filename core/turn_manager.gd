extends Node
class_name TurnManager

var turn := 0
var direction := 1
var _reverses_left := 0
var _skips_left := 0

signal turn_advanced()

func initialize(_turn: int) -> void:
	turn = _turn

func advance_turn() -> Signal:
	_update_turn()	
	return turn_advanced

func set_reverses(amount: int) -> void:
	_reverses_left = amount

func set_skips(amount: int) -> void:
	_skips_left = amount

# -------------------------
# Internal
# -------------------------

func _update_turn() -> void:
	print("pretending advancing turn...")
	await get_tree().create_timer(3).timeout
	print("pretended successfully!")
	
	emit_signal("turn_advanced")
