extends Node2D
class_name DiscardPile

signal play_requested(card: CardView)
signal play_routine_ended()

@export var fx_manager : FXManager

@export var card_scene : PackedScene

@export var animation_player : AnimationPlayer
@export var _particles : GPUParticles2D
@export var _area_outline : Sprite2D
@export var _drop_zone : DropZone
@export var _cards_node : Node2D
@export var _audio_player : AudioStreamPlayer

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

		tween.tween_property(c, "position", target_pos, 0.5)
		tween.tween_property(c, "scale", Vector2(1.2, 1.2), 0.5)

	await tween.finished

	for i in range(played_cards.size()):
		var card = played_cards[i]
		await _play_card_animation(card)
		_audio_player.pitch_scale = 1.0 + i * 0.1
		_audio_player.play()

		_play_particles(card.data.hue)
		fx_manager.play_camera_zoom_shake()

		var fx_tween = card.animate("fx").set_parallel()

		card._fx_transform.scale = Vector2(1.2, 1.2)

		fx_tween.tween_property(card._fx_transform, "scale", Vector2(1.0, 1.0), 0.35)

		var shader_color : Vector3 = _area_outline.material.get_shader_parameter("_color_ow")
		var shader_alpha : float = _area_outline.material.get_shader_parameter("_alpha")

		_set_shader_parameters(_area_outline.material, "_alpha", shader_alpha)
		_set_shader_parameters(_area_outline.material, "_color_ow", shader_color)
		_area_outline.scale = Vector2(3.5, 3.5)

		_animate_outline_state(Vector2(3.0, 3.0), 0.25, Vector3(1.0, 1.0, 1.0))

	emit_signal("play_routine_ended")

func _set_playable(playable: bool) -> void:
	_toggle_playable(playable)

# -------------------------
# Animations

func _play_card_animation(card_view: CardView) -> void:
	var tween = card_view.animate("fx").set_parallel()

	tween.tween_property(card_view, "position", Vector2.ZERO, 0.35).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_IN)
	tween.tween_property(card_view, "scale", Vector2.ONE, 0.35).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_IN)

	tween.set_parallel(false)

	await tween.finished

func _play_particles(hue: CardData.Hue) -> void:
	_particles.restart()

	var _color_matched : Color = _particles.get_meta(str(hue), Color(1., 1., 1., 1.))

	_particles.modulate = _color_matched
	_particles.emitting = true

func _toggle_playable(playable: bool) -> void:
	if playable:
		_animate_outline_state(Vector2(3.5, 3.5), 1.0, Vector3(1.0, 0.75, 0.0))
	else:
		_animate_outline_state(Vector2(3.0, 3.0), 0.25, Vector3(1.0, 1.0, 1.0))

func _animate_outline_state(target_scale: Vector2, target_alpha: float, target_color: Vector3) -> void:
	var tween := _animate("outline").set_trans(Tween.TRANS_ELASTIC).set_parallel()
	var shader_material := _area_outline.material as ShaderMaterial

	assert(shader_material != null, "DiscardPile outline material must be a ShaderMaterial")

	var initial_state := _get_shader_parameters(shader_material, ["_color_ow", "_alpha"])

	tween.tween_property(_area_outline, "scale", target_scale, 1)
	_tween_shader_parameter(tween, shader_material, "_alpha", initial_state["_alpha"] as float, target_alpha)
	_tween_shader_parameter(tween, shader_material, "_color_ow", initial_state["_color_ow"] as Vector3, target_color)

func _tween_shader_parameter( tween: Tween, shader_material: ShaderMaterial, parameter_name: String, from_value: Variant, to_value: Variant, duration := 1.0) -> void:
	tween.tween_method(func(value: Variant):
		shader_material.set_shader_parameter(parameter_name, value),
		from_value,
		to_value,
		duration)

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

# -------------------------
# Handlers
# -------------------------

func _get_shader_parameters(shader_material: ShaderMaterial, parameter_names: Array[String]) -> Dictionary[String, Variant]:
	var result : Dictionary[String, Variant] = {}

	for parameter_name in parameter_names:
		result[parameter_name] = shader_material.get_shader_parameter(parameter_name)

	return result

func _set_shader_parameters(shader_material: ShaderMaterial, parameter: String, value: Variant):
	shader_material.set_shader_parameter(parameter, value)
