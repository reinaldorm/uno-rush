extends Node2D
class_name DiscardPile

signal play_requested(card: CardView)

@export var card_scene : PackedScene
@export var animation_player : AnimationPlayer
@export var particles : GPUParticles2D
@export var cards_node : Node2D

var card_pile : Array[CardView] = []
var requested_cards : Array[CardView]

var _tween : Tween

# -------------------------
# Public API
# -------------------------

func start(first_card: CardData) -> void:
	var c : CardView = card_scene.instantiate()
	c.setup(first_card, false)
	card_pile.append(c)
	cards_node.add_child(c)

func accept_play_request() -> void:
	particles.restart()
	var last_card := requested_cards[requested_cards.size() - 1]
	_emit_particles(last_card.data.hue)
	
	for card in requested_cards: _add_card_to_pile(card)
	requested_cards = []
	particles.emitting = true

func deny_play_request() -> void:
	requested_cards = []

# -------------------------
# Internal
# -------------------------

func _toggle_playable(value: bool) -> void:
	if value: animation_player.play("show_bubbles")
	else: animation_player.play_backwards("show_bubbles")

func _new_tween(e:= Tween.EASE_OUT, t:= Tween.TRANS_EXPO) -> Tween:
	if _tween: _tween.kill()

	_tween = create_tween()
	_tween.set_ease(e)
	_tween.set_trans(t)
	
	return _tween

func _add_card_to_pile(card_view: CardView):
	card_view.reparent(cards_node)
	card_view.position = Vector2.ZERO
	card_view.drag_component.disable()

func _emit_particles(hue: CardData.Hue) -> void:
	#print(particles.process_material.color)
	pass

# -------------------------
# Handlers
# -------------------------

func _on_drag_component_entered(drag: DragComponent) -> void:
	if drag.owner is CardView:
		pass

func _on_drop_requested(draggable: Node2D) -> void:
	var cards_to_request : Array[CardData] = []
	if draggable is CardView:
		requested_cards.append(draggable)
		cards_to_request.append(draggable.data)
		emit_signal("play_requested", cards_to_request)

func _on_mouse_entered() -> void:
	_toggle_playable(true)

func _on_mouse_exited() -> void:
	_toggle_playable(false)
