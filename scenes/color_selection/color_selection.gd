extends Control
class_name HueSelection

signal hue_selected(hue: CardData.Hue) 

@export var _select_timer : Timer
@export var _select_max_time: float

var _hue_buttons : Array[Button] = []
var _tick := 0.0

# -------------------------
# Public API
# -------------------------

func start_selection() -> void:
	_select_timer.start(_select_max_time)

# -------------------------
# Internal
# -------------------------

func _ready():
	for child in $Buttons.get_children():
		if child is Button:
			_hue_buttons.append(child)

func _process(delta: float) -> void:
	_tick += delta
	
	_idle()

func _idle() -> void:
	for button in _hue_buttons:
		pass

func _select_hue(hue: CardData.Hue) -> void:
	# TODO
	# Animate Card Selection
	# TODO
	emit_signal("hue_selected", hue)

# -------------------------
# Handlers
# -------------------------

func _on_button_pressed(_hue: String) -> void:
	_select_timer.stop()
	var selected_hue : CardData.Hue

	match _hue:
		"red": selected_hue = CardData.Hue.RED
		"green": selected_hue = CardData.Hue.GREEN
		"blue": selected_hue = CardData.Hue.BLUE
		"green": selected_hue = CardData.Hue.YELLOW
	
	_select_hue(selected_hue)

func _on_select_timeout() -> void:
	var random_hue : CardData.Hue = CardData.Hue.values().pick_random()

	while random_hue == CardData.Hue.WILD:
		random_hue = CardData.Hue.values().pick_random()

	_select_hue(random_hue)
	