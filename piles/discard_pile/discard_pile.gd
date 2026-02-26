extends Node2D
class_name DiscardPile

signal play_requested(card: CardView)
signal play_routine_ended()

@export var card_scene : PackedScene

@export var animation_player : AnimationPlayer
@export var _particles : GPUParticles2D
@export var _area_outline : Sprite2D
@export var _drop_zone : DropZone
@export var _cards_node : Node2D

var _tween_channels : Dictionary[String, Tween] = {
	"play": null,
	"outline": null
}

# -------------------------
# Public API (game-manager communication)
# -------------------------

func start(first_card: CardData) -> void:
	var c : CardView = card_scene.instantiate()
	c.setup(first_card, false)
	c.drag_component.queue_free()
	_cards_node.add_child(c)

func confirm_play(played_cards: Array[CardView]) -> void:
	_drop_zone.resolve_drop(true)

	for card in played_cards:
		_add_card_to_pile(card)

	await _animate_play_sequence(played_cards)

func reject_play() -> void:
	_drop_zone.resolve_drop(false)

# -------------------------
# Internal
# -------------------------

func _add_card_to_pile(card_view: CardView):
	card_view.reparent(_cards_node)
	card_view.drag_component.queue_free()
	card_view.reset()

func _animate_play_sequence(played_cards: Array[CardView]) -> void:
	print("DiscardPile: Play sequence initiated", played_cards)

	var tween := _animate("play", Tween.EASE_OUT, Tween.TRANS_EXPO).set_parallel()

	for idx in range(played_cards.size()):
		var c : CardView = played_cards[idx]
		c.z_index = 0

		var target_angle = idx * TAU / played_cards.size()
		var target_pos = Vector2(
			70 * cos(target_angle - PI / 2),
			70 * sin(target_angle - PI / 2)
		)

		tween.tween_property(c, "position", target_pos, 0.75)
		tween.tween_property(c, "scale", Vector2(1.2, 1.2), 0.75)

	await tween.finished

	for card in played_cards:
		await _play_card_animation(card)
		_play_particles(card.data.hue)

	emit_signal("play_routine_ended")

func _set_playable(playable: bool) -> void:
	_toggle_playable(playable)

# -------------------------
# Animations

func _play_card_animation(card_view: CardView) -> void:
	# _play_particles(card_view.data.hue)

	var tween = card_view.animate("fx").set_parallel()

	tween.tween_property(card_view, "position", Vector2.ZERO, 0.75).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_IN)
	tween.tween_property(card_view, "scale", Vector2.ONE, 0.75).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_IN)

	await tween.finished

func _play_particles(hue: CardData.Hue) -> void:
	_particles.restart()

	var _color_matched : Color = _particles.get_meta(str(hue), Color(1., 1., 1., 1.))

	_particles.modulate = _color_matched
	_particles.emitting = true

func _toggle_playable(playable: bool) -> void:
	# This function is WAY too long and should be desmembrated into smaller functions.
	# TODO: Refactor this function into smaller functions.
	if playable:
		var tween := _animate("outline").set_trans(Tween.TRANS_ELASTIC).set_parallel()

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
	else:
		var tween := _animate("outline").set_trans(Tween.TRANS_ELASTIC).set_parallel()

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

func _animate(channel: String, e:= Tween.EASE_OUT, t:= Tween.TRANS_EXPO) -> Tween:
	if _tween_channels[channel]: _tween_channels[channel].kill()

	_tween_channels[channel] = create_tween()
	_tween_channels[channel].set_ease(e)
	_tween_channels[channel].set_trans(t)

	return _tween_channels[channel]

# -------------------------
# Handlers
# -------------------------

func _on_drag_component_entered(draggable: Node2D) -> void:
	if draggable: _set_playable(true)
	pass

func _on_drag_component_exited(_draggable: Node2D = null) -> void:
	_set_playable(false)

func _on_card_drop_requested(draggable: Node2D) -> void:
	# user tried to drop a card onto the discard pile; forward the
	# underlying data to the game manager via the public signal.

	if draggable is CardView: emit_signal("play_requested", GameManager.PlayRequestType.DROP)

	# TODO
	# Should no execute this directly, this animation should be turned into a method
	# doing it now for the sake of simplicity
	# TODO

	_on_drag_component_exited()

func _on_mouse_entered() -> void:
	_set_playable(true)

func _on_mouse_exited() -> void:
	_set_playable(false)

func _on_button_pressed():
	emit_signal("play_requested", GameManager.PlayRequestType.PRESS)
