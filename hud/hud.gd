extends CanvasLayer
class_name HUD

signal skip_turn()
signal arrange_number()
signal arranger_color()

@export var _opponent_boxes : Array[OpponentBox]

@export var _uno_button : CardButton

@export var _turn_wheel : TurnWheel
@export var _turn_label : RichTextLabel
@export var _turn_particle : GPUParticles2D

var _opponent_mapped : Dictionary[int, OpponentBox]
var _tween : Tween

# -------------------------
# Public API
# -------------------------

func set_opponent_box(opponent_id: int, order: int, hand_count: int, is_current: bool) -> void:
	var box := _opponent_boxes[order]
	box.show()

	box.set_name(str(opponent_id))
	_opponent_mapped[opponent_id] = box

	update_opponent(opponent_id, hand_count, is_current)

func update_opponent(opponent_id: int, hand_count: int, is_current: bool) -> void:
	var box := _opponent_mapped[opponent_id]
	box.update_cards(hand_count)
	box.update_turn(is_current)

func update_player_hand(is_current: bool) -> void:
	if is_current:
		_show_client_turn()
	else:
		_hide_client_turn()

# -------------------------
# Internal
# -------------------------

func _ready() -> void:
	for box in _opponent_boxes:
		box.hide()
	_uno_button.disable()

func _show_client_turn() -> void:
	_tween = TweenHelper.new_tween(_tween, self).set_parallel().set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)

	_tween.tween_property(_turn_label, "scale", Vector2.ONE, 1.5)
	_turn_wheel.turn_client()


	_turn_particle.restart()
	_turn_particle.emitting = true

func _hide_client_turn() -> void:
	_tween = TweenHelper.new_tween(_tween, self).set_parallel().set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)

	_tween.tween_property(_turn_label, "scale", Vector2.ZERO, 0.5).set_trans(Tween.TRANS_EXPO)
	_turn_wheel.turn_opponent()

# -------------------------
# Handlers
# -------------------------

func _on_skip_turn_pressed() -> void:
	emit_signal("skip_turn")

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.is_action_pressed("ui_down"):
			emit_signal("skip_turn")
