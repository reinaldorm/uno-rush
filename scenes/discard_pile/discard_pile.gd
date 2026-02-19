extends Control
class_name DiscardPile

@export var warn_text : RichTextLabel
@export var attach_component : AttachComponent

func _on_attach_component_card_entered() -> void:
	CardManager.attach_card(attach_component)

func _on_attach_component_card_exited() -> void:
	CardManager.dettach_card()

func _on_attach_component_card_dropped(card: Card) -> void:
	print("C")
	var hand : Hand = card.get_parent()
	hand.cards = hand.cards.filter(func(c: Card): return c != card)
	card.reparent(self)
