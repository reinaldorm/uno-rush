@tool
extends Node2D
class_name Hand

@export var card_scene : PackedScene
@export var layout_component : HandLayoutComponent

@export_category("DEV_ENV")
@export var DEV_layout_max_width_overwrite := 300.0

var card_data : Array[CardData] = []
var card_views : Array[CardView] = []
var moving_card : CardView = null

# -------------------------
# Public API
# -------------------------

func start(cards: Array[CardData]) -> void:
	add_cards(cards)

func add_cards(cards: Array[CardData], should_arrange: bool = true) -> void:
	for data in cards:
		card_data.append(data)
		
		var card_view : CardView = card_scene.instantiate()
		card_view.setup(data, true)
		
		add_child(card_view)
		card_views.append(card_view)
		
		card_view.drag_component.drag_started.connect(_on_card_drag_started)
		card_view.drag_component.drag_ended.connect(_on_card_drag_ended)
		
		card_view.drag_component.drop_zone_entered.connect(_on_card_drop_zone_entered)
		card_view.drag_component.drop_zone_exited.connect(_on_card_drop_zone_exited)
		
	if should_arrange: _arrange()

# -------------------------
# Internal
# -------------------------

func _ready() -> void:
	if DEV_layout_max_width_overwrite: layout_component.max_arrange_width = DEV_layout_max_width_overwrite
	for child in get_children():
		if child is CardView:
			card_views.append(child)
	_arrange()

func _arrange() -> void:
	layout_component.arrange(card_views)

func _process(_delta: float) -> void:
	if moving_card: _sort_moving_card(moving_card)

# -------------------------
# Handlers
# -------------------------

func _on_game_manager_cards_played(cards: Array[CardView]) -> void:
	for card in cards:
		if card_data.has(card.data):
			card_data.erase(card.data)
			card_views.erase(card)

func _on_card_drag_started(_draggable: Node2D) -> void:
	moving_card = _draggable
	#_arrange()

func _on_card_drag_ended(_draggable: Node2D) -> void:
	moving_card = null
	_arrange()

func _on_card_drop_zone_entered(draggable: Node2D, _drop_zone: DropZone) -> void:
	if draggable is CardView:
		if card_views.has(draggable): 
			card_views.erase(draggable)

func _on_card_drop_zone_exited(draggable: Node2D, _drop_zone: DropZone) -> void:
	if draggable is CardView:
		if card_data.has(draggable.data): 
			card_views.append(draggable)

func _sort_moving_card(card_view: CardView) -> void:
	var card_index = card_views.find(card_view)
	
	if card_index - 1 >= 0:
		var previous_simbling := card_views[card_index - 1]
		
		if previous_simbling.position.x - card_view.position.x > 0.0:
			var temp := previous_simbling
			card_views[card_index - 1] = card_view
			card_views[card_index] = temp
			_arrange()

	if card_index + 1 < card_views.size():
		var next_simbling := card_views[card_index + 1]
		
		if next_simbling.position.x - card_view.position.x < 0.0:
			var temp := next_simbling
			card_views[card_index + 1] = card_view
			card_views[card_index] = temp
			_arrange()
