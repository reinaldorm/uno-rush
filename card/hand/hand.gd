@tool
extends Node2D
class_name Hand

@export var drag_layer : DragLayer
@export var card_scene : PackedScene
@export var layout_component : HandLayoutComponent

var card_data : Array[CardData] = []
var card_views : Array[CardView] = []

# -------------------------
# Public API
# -------------------------

func add_card(data: CardData) -> void:
	card_data.append(data)
	
	var view : CardView = card_scene.instantiate()
	view.setup(data, true)
	
	add_child(view)
	card_views.append(view)
	
	view.drag_component.drag_started.connect(drag_layer.begin_drag)
	view.drag_component.drag_ended.connect(drag_layer.end_drag)
	
	_arrange()

# -------------------------
# Internal
# -------------------------

func _arrange() -> void:
	layout_component.arrange(card_views)

# -------------------------
# Handlers
# -------------------------
