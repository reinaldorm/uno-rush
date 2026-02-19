extends Node

var held_card : Card
var attached_component : AttachComponent

##

func hold_card(card: Card) -> void:
	held_card = card
	
	if card.tween_arange: card.tween_arange.kill()
	held_card.animate_scale(Vector2(1.5, 1.5))
	held_card.animate_rot()
	held_card.being_held = true

func drop_card(card: Card) -> void:
	if attached_component:
		attached_component.card_dropped.emit(held_card)
		attached_component = null

	held_card = null
	card.being_held = false

func attach_card(attach_component: AttachComponent) -> void:
	if held_card: 
		held_card.animate_scale(Vector2(2.25, 2.25))
		held_card.animate_rot()
		attached_component = attach_component

##

func _process(_delta: float) -> void:
	if held_card:
		var mouse_pos : Vector2 = get_viewport().get_mouse_position()
		held_card.global_position = held_card.global_position.lerp(mouse_pos, 0.5)
