extends Node
class_name HueManager

signal hue_selected

@export var hue_selection_node: HueSelection

var hue : CardData.Hue

# -------------------------
# Public API
# -------------------------

func initialize(_hue: CardData.Hue) -> void:
	hue = _hue
	hue_selection_node.hide()

func set_hue(_hue: CardData.Hue) -> void:
	hue = _hue

func prompt_hue_selection() -> Signal:
	_run_hue_selection_flow()
	return hue_selected

# -------------------------
# Internal
# -------------------------

func _run_hue_selection_flow() -> void:
	print("HueManager: Starting hue selection flow...")
	hue_selection_node.start_selection()

func _on_hue_selected(_hue: CardData.Hue) -> void:
	print("HueManager: Hue selected: ", _hue)
	hue = _hue
	emit_signal("hue_selected")
