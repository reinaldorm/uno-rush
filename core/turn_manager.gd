extends Node
class_name TurnManager

var turn := 0
var direction := 1
var reverse := bool

func setup(_turn: int) -> void:
    turn = _turn