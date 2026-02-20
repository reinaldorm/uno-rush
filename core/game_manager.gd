extends Node
class_name GameManager

@export var hand : Hand
@export var draw_pile : DrawPile
@export var discard_pile : DiscardPile



func validate_play(cards: Array[CardData]) -> void:
	pass;
