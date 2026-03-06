extends CanvasLayer
class_name HUD

signal skip_turn()

@export var player_turn_label : RichTextLabel
@export var opponent_boxes : Array[OpponentBox]
@export var turn_button : CardButton

var opponent_boxes_mapped : Dictionary[int, OpponentBox]

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
		player_turn_label.show()
		turn_button.enable()
	else:
		player_turn_label.hide()
		turn_button.disable()

# -------------------------
# Internal
# -------------------------

func _ready() -> void:
	for box in opponent_boxes:
		box.hide()

# -------------------------
# Handlers
# -------------------------

func _on_skip_turn_pressed() -> void:
	emit_signal("skip_turn")
