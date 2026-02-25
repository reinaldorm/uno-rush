extends Node2D
class_name DiscardPile

signal play_requested(card: CardView)
signal play_routine_ended()

@export var card_scene : PackedScene

@export var animation_player : AnimationPlayer
@export var _particles : GPUParticles2D
@export var cards_node : Node2D
@export var _area_outline : Sprite2D
@export var _drop_zone : DropZone

var card_pile : Array[CardView] = []
var requested_cards : Array[CardView]

var _tween : Tween

# -------------------------
# Public API (game-manager communication)
# -------------------------

func start(first_card: CardData) -> void:
	var c : CardView = card_scene.instantiate()
	c.setup(first_card, false)
	card_pile.append(c)
	cards_node.add_child(c)

# Called by the GameManager when a previously requested play has been
# validated and may be committed. The pile will accept the cards and
# fire the visual effects associated with a successful play.
func confirm_play() -> void:
	_drop_zone.resolve_drop(true)

	for card in requested_cards:
		_add_card_to_pile(card)

	# play the visual sequence for the newly added cards, then notify
	await _animate_play_sequence(requested_cards)

	requested_cards = []

# Called by the GameManager when a requested play is rejected. The pile
# clears any pending cards and signals the drop zone that the attempt
# failed so the card(s) can return to the hand.
func reject_play() -> void:
	requested_cards = []
	_drop_zone.resolve_drop(false)

# -------------------------
# Internal
# -------------------------

func _add_card_to_pile(card_view: CardView):
	card_view.reparent(cards_node)
	card_view.position = Vector2.ZERO
	card_view.drag_component.queue_free()

# the animation sequence that runs when cards are played.
# `played_cards` is the array that was just appended to the pile; the
# function rearranges the pile and then animates each card in turn.
func _animate_play_sequence(played_cards: Array[CardView]) -> void:
	var tween := _new_tween().set_parallel()

	for idx in range(card_pile.size()):
		var c : CardView = card_pile[idx]
		var target_angle = idx * TAU / card_pile.size()
		var target_pos = Vector2(
			cards_node.size.x * 0.5 * cos(target_angle),
			cards_node.size.y * 0.5 * sin(target_angle)
		)
		tween.tween_property(c, "position", target_pos, 0.25)

	await tween.finished

	for card in card_pile:
		await _play_card_animation(card)

	emit_signal("play_routine_ended")

# -------------------------
# Animations

# play the animation for a single card in the pile. the caller
# waits on the returned signal so cards animate sequentially.
func _play_card_animation(card_view: CardView) -> Signal:
	_play_particles(card_view.data.hue)

	var tween = card_view.animate("fx")
	var center_dir = (Vector2.ZERO - card_view.position).normalized()

	tween.tween_property(card_view, "position", -center_dir * 20, 0.25)
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(card_view, "position", Vector2.ZERO, 0.75)
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)

	return tween.finished

func _play_particles(hue: CardData.Hue) -> void:
	_particles.reset()

	var _color_matched : Color = _particles.get_metadata(hue)
	_particles.modulate = _color_matched
	_particles.emitting = true

func _new_tween(e:= Tween.EASE_OUT, t:= Tween.TRANS_EXPO) -> Tween:
	if _tween: _tween.kill()

	_tween = create_tween()
	_tween.set_ease(e)
	_tween.set_trans(t)

	return _tween

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

func _on_card_drop_requested(draggable: Node2D) -> void:
	# user tried to drop a card onto the discard pile; forward the
	# underlying data to the game manager via the public signal.
	var cards_to_request : Array[CardData] = []
	if draggable is CardView:
		requested_cards.append(draggable)
		cards_to_request.append(draggable.data)
		emit_signal("play_requested", cards_to_request)

func _on_mouse_entered() -> void:
	_toggle_playable(true)

func _on_mouse_exited() -> void:
	_toggle_playable(false)
