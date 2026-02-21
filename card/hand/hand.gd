@tool
extends Node2D
class_name Hand

@export var card_scene : PackedScene
@export var layout_component : HandLayoutComponent

var card_data : Array[CardData] = []
var card_views : Array[CardView] = []

# -------------------------
# Public API
# -------------------------

func start(cards: Array[CardData]) -> void:
	add_cards(cards)

func add_cards(cards: Array[CardData], should_arrange: bool = true) -> void:
	for data in cards:
		card_data.append(data)
		
		var view : CardView = card_scene.instantiate()
		view.setup(data, true)
		
		add_child(view)
		card_views.append(view)
		
		#view.drag_component.drag_started.connect(drag_layer.begin_drag)
		view.drag_component.drag_started.connect(_on_view_drag_started)
		view.drag_component.drag_ended.connect(_on_view_drag_ended)
		
	if should_arrange: _arrange()

# -------------------------
# Internal
# -------------------------

func _ready() -> void:
	pass

func _arrange() -> void:
	layout_component.arrange(card_views)

# -------------------------
# Handlers
# -------------------------

func _on_view_drag_started(_draggable: Node2D) -> void:
	_arrange()

func _on_view_drag_ended(_draggable: Node2D) -> void:
	_arrange()

# -------------------------
# DEBUG
# -------------------------

@export_category("DEBUG")
@export_subgroup("Gap Slider")
@export var gap_slider : HSlider
@export var gap_slider_label : Label
@export_subgroup("Max Width Slider")
@export var max_width_slider : HSlider
@export var max_width_slider_label : Label
@export var max_width_preview : ColorRect

func _on_gap_slider_value_changed(value: float) -> void:
	layout_component.max_arrange_gap = gap_slider.value
	gap_slider_label.text = "GAP: " + str(gap_slider.value)
	_arrange()
	
func _on_max_width_slider_value_changed(value: float) -> void:
	layout_component.max_arrange_width = max_width_slider.value
	max_width_preview.size.x = max_width_slider.value
	max_width_preview.position.x = -(max_width_slider.value / 2)
	max_width_slider_label.text = "MAX WIDTH: " + str(max_width_slider.value)
	_arrange()
