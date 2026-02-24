extends Control
class_name HueSelection

signal hue_selected(hue: CardData.Hue) 

var _hue_buttons : Array[Button] = []
var _tick := 0.0

# -------------------------
# Public API
# -------------------------

func show_selection() -> Signal:
	return hue_selected

func hide_selection():
	pass

# -------------------------
# Internal
# -------------------------

func _ready():
	for child in $Buttons.get_children():
		if child is Button:
			_hue_buttons.append(child)
	print(_hue_buttons) 

func _process(delta: float) -> void:
	_tick += delta
	
	_idle()

func _idle() -> void:
	for button in _hue_buttons:
		pass

# -------------------------
# Handlers
# -------------------------

func _on_hue_selected(_hue: String) -> void:
	var selected_hue : CardData.Hue
	match _hue:
		"red": selected_hue = CardData.Hue.RED
		"green": selected_hue = CardData.Hue.GREEN
		"blue": selected_hue = CardData.Hue.BLUE
		"green": selected_hue = CardData.Hue.YELLOW
	
	print(_hue)

	emit_signal("hue_selected", selected_hue)