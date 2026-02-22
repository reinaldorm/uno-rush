@tool
extends Node2D
class_name DiscardPile

signal play_requested(card: CardView)

@export var card_scene : PackedScene

var card_pile : Array[CardView] = []

# -------------------------
# Public API
# -------------------------

func start(first_card: CardData) -> void:
	var c : CardView = card_scene.instantiate()
	c.setup(first_card, false)
	add_child(c)
	card_pile.append(c)

func accept_play_request(card: CardView) -> void:
	card.reparent(self)
	card.drag_component.disable()

func deny_play_request(card: CardView) -> void:
	#drag_layer.restore_to_original_parent(card)
	pass

# -------------------------
# Internal
# -------------------------

##

# -------------------------
# Handlers
# -------------------------

func _on_drag_component_entered(drag: DragComponent) -> void:
	if drag.owner is CardView:
		pass;

func _on_drop_requested(draggable: Node2D) -> void:
	if draggable is CardView:
		emit_signal("play_requested", draggable)
