extends Node2D
class_name DiscardPile

signal play_requested(card: CardView)

@export var card_scene : PackedScene

@export var animation_player : AnimationPlayer
@export var particles : GPUParticles2D
@export var cards_node : Node2D
@export var _area_outline : Sprite2D
@export var _drop_zone : DropZone

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
	_emit_particles()

	for card in requested_cards: _add_card_to_pile(card)

	requested_cards = []
	_drop_zone.resolve_drop(true)

func deny_play_request() -> void:
	requested_cards = []
	_drop_zone.resolve_drop(false)

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
	card_view.drag_component.queue_free()

func _emit_particles() -> void:
	particles.emitting = true

# -------------------------
# Handlers
# -------------------------

func _on_drag_component_entered(draggable: Node2D) -> void:
	if draggable is CardView:
		var tween := _new_tween().set_trans(Tween.TRANS_ELASTIC).set_parallel()

		var shader_color : Vector3 = _area_outline.material.get_shader_parameter("_color_ow")
		var shader_alpha : float = _area_outline.material.get_shader_parameter("_alpha")

		tween.tween_property(_area_outline, "scale", Vector2(3.5, 3.5), 1)

		tween.tween_method(func(value: float):
			_area_outline.material.set_shader_parameter("_alpha", value),
			shader_alpha,
			1.0,
			1)

		tween.tween_method(func(value: Vector3):
			_area_outline.material.set_shader_parameter("_color_ow", value),
			shader_color,
			Vector3(1.0, 0.75, 0.0),
			1)

func _on_drag_component_exited(draggable: Node2D) -> void:
	if draggable is CardView:
		var tween := _new_tween().set_trans(Tween.TRANS_ELASTIC).set_parallel()

		var shader_color : Vector3 = _area_outline.material.get_shader_parameter("_color_ow")
		var shader_alpha : float = _area_outline.material.get_shader_parameter("_alpha")

		tween.tween_property(_area_outline, "scale", Vector2(3.0, 3.0), 1)

		tween.tween_method(func(value: float):
			_area_outline.material.set_shader_parameter("_alpha", value),
			shader_alpha,
			0.25,
			1)

		tween.tween_method(func(value: Vector3):
			_area_outline.material.set_shader_parameter("_color_ow", value),
			shader_color,
			Vector3(1.0, 1.0, 1.0),
			1)

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
