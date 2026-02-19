extends Control
class_name DiscardPile

@export var warn_text : RichTextLabel
@export var attach_component : AttachComponent

func _on_attach_component_card_entered() -> void:
	CardManager.attach_card(attach_component)

func _on_attach_component_card_exited() -> void:
	pass

func _on_attach_component_card_dropped(card: Card) -> void:
	card.reparent(self)
