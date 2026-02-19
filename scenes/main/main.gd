extends Control
class_name Main

@export var hand : Hand
@export var draw_pile : DrawPile
@export var discard_pile : DiscardPile

func _ready() -> void:
    for i in range(9): 
        var card_res : Dictionary = CardData.create(CardData.COLOR.values().pick_random(), i)
        hand.add_card(card_res)
    hand.arrange_hand()
