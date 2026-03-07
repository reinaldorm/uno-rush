extends CanvasLayer
class_name HUD

signal skip_turn()
signal arrange_number
signal arranger_color

@export var opponent_boxes : Array[OpponentBox]
@export var turn_button : CardButton
@export var turn_label : RichTextLabel
@export var turn_particle : GPUParticles2D
@export var uno_button : CardButton

var opponent_boxes_mapped : Dictionary[int, OpponentBox]
var _tween : Tween

# -------------------------
# Public API
# -------------------------

func set_opponent_box(opponent_id: int, order: int, hand_count: int, is_current: bool) -> void:
	var box := opponent_boxes[order]
	box.show()

	box.set_name(str(opponent_id))
	opponent_boxes_mapped[opponent_id] = box

	update_opponent(opponent_id, hand_count, is_current)

func update_opponent(opponent_id: int, hand_count: int, is_current: bool) -> void:
	var box := opponent_boxes_mapped[opponent_id]
	box.update_cards(hand_count)
	box.update_turn(is_current)

func update_player_hand(is_current: bool) -> void:
	if is_current:
		_show_client_turn()
	else:
		turn_particle.restart()
		turn_label.hide()
		turn_button.disable()

# -------------------------
# Internal
# -------------------------

func _ready() -> void:
	for box in opponent_boxes:
		box.hide()
	uno_button.disable()

func _show_client_turn() -> void:
	_tween = TweenHelper.new_tween(_tween, self).set_parallel().set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)

	turn_label.rotation = randf_range(-0.5, 0.5)
	turn_label.scale = Vector2.ONE * 1.5

	_tween.tween_property(turn_label, "scale", Vector2.ONE, 0.75)
	_tween.tween_property(turn_label, "rotation", 0.0, 0.75)

	turn_label.show()
	turn_particle.restart()
	turn_particle.emitting = true
	turn_button.enable()

# -------------------------
# Handlers
# -------------------------

func _on_skip_turn_pressed() -> void:
	emit_signal("skip_turn")
