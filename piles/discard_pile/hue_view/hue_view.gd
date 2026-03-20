extends Node2D
class_name HueView

@export var sheet_sprite : Sprite2D

func set_hue(hue: CardData.Hue) -> void:
	sheet_sprite.frame = hue