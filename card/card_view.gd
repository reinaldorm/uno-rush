class_name CardView
extends Node2D

signal mouse_left_down(card_view: CardView)
signal mouse_right_down(card_view: CardView)

@export var drag_component : DragComponent

@export var _card_sheet : Sprite2D
@export var _card_sprite : Sprite2D

@export var _selection_transform : Node2D
@export var _hover_transform : Node2D
@export var _fx_transform : Node2D

@export var _bubbles_player : AnimationPlayer
@export var _card_player : AnimationPlayer

@export var size : Vector2

@export var data : CardData

var is_selected := false

var _tween_channels : Dictionary[String, Tween] = {
	"fx": null,
	"layout": null,
	"hover": null ,
	"selection": null
}

var _tick := 0.0

# -------------------------
# Public API
# -------------------------

func setup(card_data: CardData, flipped:= false) -> void:
	data = card_data

	_card_sheet.frame_coords = _get_texture_coord()

	set_flip(flipped)

## Animation API
## -------------------------

func animate(channel: String, e:= Tween.EASE_OUT, t:= Tween.TRANS_ELASTIC) -> Tween:
	if _tween_channels[channel]: _tween_channels[channel].kill()

	_tween_channels[channel] = create_tween()
	_tween_channels[channel].set_ease(e)
	_tween_channels[channel].set_trans(t)

	return _tween_channels[channel]

func animate_flip(backwards := false) -> Signal:
	if backwards: _card_player.play_backwards("flip")
	else: _card_player.play("flip")
	return _card_player.animation_finished

func set_flip(backwards := false) -> void:
	if backwards:
		_card_sheet.frame_coords = Vector2(11, 4)
	else:
		_card_sheet.frame_coords = _get_texture_coord()

func set_draggable() -> void:
	pass;

func set_selected(state: bool, _order := -1) -> void:
	is_selected = state
	_toggle_select(state)

func set_playable(state: bool) -> void:
	_toggle_playable(state)

func reset() -> void:
	for tween in _tween_channels.values():
		if tween: tween.kill()

	_toggle_playable(false)
	_toggle_select(false)

	_selection_transform.scale = Vector2(1.0, 1.0)
	_selection_transform.rotation = 0.0

	_hover_transform.scale = Vector2(1.0, 1.0)
	_hover_transform.rotation = 0.0

	_fx_transform.scale = Vector2(1.0, 1.0)
	_fx_transform.rotation = 0.

	scale = Vector2(1.0, 1.0)

# -------------------------
# Internal
# -------------------------

func _idle() -> void:
	pass

func _process(delta: float) -> void:
	_tick += delta

	_idle()

func _toggle_select(state: bool) -> void:
	var tween = animate("selection")
	tween.set_parallel()

	if state:
		tween.tween_property(_selection_transform, "scale", Vector2(1.1, 1.1), 1.0)
	else:
		tween.tween_property(_selection_transform, "scale", Vector2(1.0, 1.0), 1.0)

func _toggle_playable(state: bool) -> void:
	if state:
		var tween = animate("fx")
		# TODO ----------
		# FIX THIS!!!!
		# TODO ----------

		# _fx_transform.scale = Vector2(1.1, 1.1)

		tween.set_loops()
		tween.tween_property(_fx_transform, "scale", Vector2(1.1, 1.1), 0.01)
		tween.tween_property(_fx_transform, "scale", Vector2.ONE, 0.75)
		tween.tween_interval(.2)
	else:
		if _tween_channels["fx"]: _tween_channels["fx"].kill()

	_card_sheet.material.set_shader_parameter("disabled", not state)

func _toggle_input_helpers(to: bool) -> void:
	if to:
		_bubbles_player.play("show_bubbles")
	else:
		_bubbles_player.play_backwards(("show_bubbles"))

func _get_texture_coord() -> Vector2i:
	var texture_coord := Vector2i(0, 0)

	if data.number >= 0:
		texture_coord = Vector2i(data.number, data.hue)
	elif data.hue == CardData.Hue.WILD:
		texture_coord = Vector2i(0, data.hue)
		if data.effect == CardData.Effect.DRAW:
			texture_coord = Vector2i(1, data.hue)
		else:
			texture_coord = Vector2i(0, data.hue)
	elif data.effect != null:
		texture_coord = Vector2i(9 + data.effect + 1, data.hue)

	return texture_coord

# -------------------------
# Handlers
# -------------------------

func _on_card_entered() -> void:
	if drag_component and drag_component.dragging: return

	_toggle_input_helpers(true)

	var tween = animate("hover")

	_hover_transform.rotation = 0.25

	tween.set_parallel()
	tween.tween_property(_hover_transform, "scale", Vector2(1.1, 1.1), 1.0)
	tween.tween_property(_hover_transform, "rotation", 0.0, 1.0)

func _on_card_exited() -> void:
	if drag_component and drag_component.dragging: return

	_toggle_input_helpers(false)

	var tween = animate("hover")

	tween.set_parallel()
	tween.tween_property(_hover_transform, "scale", Vector2(1.0, 1.0), 1.0)
	tween.tween_property(_hover_transform, "rotation", 0.0, 1.0)

func _on_drag_started(_owner: Node2D) -> void:
	if _tween_channels["layout"]: _tween_channels["layout"].kill()
	set_selected(false)
	set_playable(false)

func _on_input_component_mouse_left_down() -> void:
	emit_signal("mouse_left_down", self)

func _on_input_component_mouse_right_down() -> void:
	emit_signal("mouse_right_down", self)
