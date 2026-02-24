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
	hue_selection_node.show()

	await get_tree().create_timer(1).timeout
	## TODO
	hue = CardData.Hue.RED
	hue_selection_node.hide()
	## TODO

	emit_signal("hue_selected")
