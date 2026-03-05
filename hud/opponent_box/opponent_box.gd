extends VBoxContainer
class_name OpponentBox

@export var name_label: RichTextLabel
@export var cards_label: RichTextLabel
@export var turn_label: RichTextLabel

# -------------------------
# Public API
# -------------------------

func update_name(_name: String) -> void:
	name_label.text = _name

func update_cards(count: int) -> void:
	cards_label.text = str(count)

func update_turn(turn: bool) -> void:
	turn_label.visible = turn

# -------------------------
# Internal
# -------------------------
