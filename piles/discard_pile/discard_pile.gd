@tool
extends Node2D
class_name DiscardPile

signal play_requested(card: CardView)

@export var card_scene : PackedScene
@export var play_bubble : Sprite2D

var card_pile : Array[CardView] = []
var _tween : Tween

# -------------------------
# Public API
# -------------------------

func start(first_card: CardData) -> void:
	var c : CardView = card_scene.instantiate()
	c.setup(first_card, false)
	card_pile.append(c)
	add_child(c)

func accept_play_request(card: CardView) -> void:
	card.reparent(self)
	card.drag_component.disable()

func deny_play_request(card: CardView) -> void:
	#drag_layer.restore_to_original_parent(card)
	pass

# -------------------------
# Internal
# -------------------------

func _toggle_idle(value: bool) -> void:
	if value:
		var tween = _new_tween()
		tween.set_loops()
		tween.tween_property(play_bubble, "rotation_degrees", 15.0, 0.25)
		tween.tween_property(play_bubble, "rotation_degrees", 25.0, 0.25)
	else: if _tween: _tween.kill()

func _new_tween(e:= Tween.EASE_OUT, t:= Tween.TransitionType.TRANS_EXPO) -> Tween:
	if _tween: _tween.kill()

	_tween = create_tween()
	_tween.set_ease(e)
	_tween.set_trans(t)
	
	return _tween

# -------------------------
# Handlers
# -------------------------

func _on_drag_component_entered(drag: DragComponent) -> void:
	if drag.owner is CardView:
		pass

func _on_drop_requested(draggable: Node2D) -> void:
	if draggable is CardView:
		emit_signal("play_requested", draggable)

func _on_mouse_entered() -> void:
	_toggle_idle(true)

func _on_mouse_exited() -> void:
	_toggle_idle(false)
