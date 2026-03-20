class_name CardView
extends Node2D

signal mouse_left_down(card_view: CardView)
signal mouse_right_down(card_view: CardView)

@export var drag_component : DragComponent

@export var _card_sheet : Sprite2D
@export var _card_sprite : Sprite2D
@export var _card_outline : Sprite2D

@export var _selection_transform : Node2D
@export var _hover_transform : Node2D
@export var _fx_transform : Node2D

@export var _bubbles_player : AnimationPlayer
@export var _card_player : AnimationPlayer

@export var size : Vector2

@export var data : CardData

var is_selected := false : set = _set_selected
var is_playable := false : set = _set_playable

var _tween_channels : Dictionary[String, Tween] = {
	"layout": null,
	"fx": null,
	"outline": null,
	"hover": null ,
	"selection": null,
	"idle": null
}

var _tick := 0.0

# -------------------------
# Public API
# -------------------------

func setup(card_data: CardData, flipped:= false) -> void:
	data = card_data

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

func reset() -> void:
	for tween in _tween_channels.values():
		if tween: tween.kill()

	is_selected = false
	is_playable = false

	scale = Vector2.ONE
	rotation = 0.0

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

func _ready() -> void:
	# _idle()
	pass

func _idle() -> void:
	var _tween := animate("idle")
	_tween.set_trans(Tween.TRANS_SINE)

func _process(delta: float) -> void:
	_tick += delta

func _toggle_select(state: bool) -> void:
	var tween = animate("selection")
	tween.set_parallel()

	if state:
		tween.tween_property(_selection_transform, "scale", Vector2(1.1, 1.1), 0.7)
	else:
		tween.tween_property(_selection_transform, "scale", Vector2(1.0, 1.0), 0.7)

func _toggle_playable(state: bool) -> void:

	var tween_fx = animate("fx")
	var tween_outline = animate("outline")
	
	if state:
		tween_fx.set_trans(Tween.TRANS_EXPO)
		tween_outline.set_trans(Tween.TRANS_EXPO)

		tween_fx.tween_property(_fx_transform, "rotation", -0.025, 0.25)
		tween_fx.tween_property(_fx_transform, "rotation", 0.025, 0.25)

		tween_outline.tween_property(_card_outline, "scale", Vector2(2.8, 2.7), 0.5)
		tween_outline.tween_property(_card_outline, "scale", Vector2(2.7, 2.6), 0.5)

		tween_fx.set_loops()
		tween_outline.set_loops()
	else:

		tween_fx.tween_property(_fx_transform, "rotation", 0.0, 1.0)
		tween_outline.tween_property(_card_outline, "scale", Vector2(2.4, 2.3), 1.0)

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
	elif data.category == CardData.Category.WILD:
		texture_coord = Vector2i(0, 4)
		if data.effect == CardData.Effect.DRAW:
			texture_coord = Vector2i(1, 4)
		else:
			texture_coord = Vector2i(0, 4)
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
	tween.tween_property(_hover_transform, "scale", Vector2(1.1, 1.1), 0.7)
	tween.tween_property(_hover_transform, "rotation", 0.0, 0.7)

func _on_card_exited() -> void:
	if drag_component and drag_component.dragging: return

	_toggle_input_helpers(false)

	var tween = animate("hover")

	tween.set_parallel()
	tween.tween_property(_hover_transform, "scale", Vector2(1.0, 1.0), 0.7)
	tween.tween_property(_hover_transform, "rotation", 0.0, 0.7)

func _on_drag_started(_owner: Node2D) -> void:
	if _tween_channels["layout"]: _tween_channels["layout"].kill()
	is_selected = false
	is_playable = false

func _on_input_component_mouse_left_down() -> void:
	emit_signal("mouse_left_down", self)

func _on_input_component_mouse_right_down() -> void:
	emit_signal("mouse_right_down", self)

# -------------------------
# Setters
# -------------------------

func _set_selected(value: bool) -> void:
	if is_selected == value: return
	is_selected = value
	_toggle_select(value)

func _set_playable(value: bool) -> void:
	if is_playable == value: return
	is_playable = value
	_toggle_playable(value)
