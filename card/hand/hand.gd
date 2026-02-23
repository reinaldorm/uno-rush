extends Node2D
class_name Hand

@export var card_scene : PackedScene
@export var layout_component : HandLayoutComponent

@export_category("DEV_ENV")
@export var DEV_layout_max_width_overwrite := 300.0

var _card_data : Array[CardData] = []
var _card_views : Array[CardView] = []
var _selected_cards : Array[CardView] = []
var moving_card : CardView = null

# -------------------------
# Public API
# -------------------------

func start(cards: Array[CardData]) -> void:
	_add_cards(cards)
	_arrange()

# -------------------------
# Internal
# -------------------------

func _ready() -> void:
	if DEV_layout_max_width_overwrite: layout_component.max_arrange_width = DEV_layout_max_width_overwrite
	for child in get_children():
		if child is CardView:
			_card_views.append(child)
			child.setup(CardData.create(randi_range(0, CardData.COLOR.size() - 1), randi_range(0, 9)), false, true)
	_arrange()

func _process(_delta: float) -> void:
	if moving_card: _sort_moving_card(moving_card)

func _arrange() -> void:
	layout_component.arrange(_card_views)

func _arrange_new(cards: Array[CardView]) -> void:
	await layout_component.arrange_new(_card_views, cards)
	_arrange()

func _add_cards(cards: Array[CardData]) -> Array[CardView]:
	var new_cards : Array[CardView] = []
	
	for data in cards:
		var card_view : CardView = card_scene.instantiate()
		
		new_cards.append(card_view)
		_card_data.append(data)
		card_view.setup(data, true)
		
		add_child(card_view)
		_card_views.append(card_view)
		
		card_view.drag_component.drag_started.connect(_on_card_drag_started)
		card_view.drag_component.drag_ended.connect(_on_card_drag_ended)
		
		card_view.drag_component.drop_zone_entered.connect(_on_card_drop_zone_entered)
		card_view.drag_component.drop_zone_exited.connect(_on_card_drop_zone_exited)

		card_view.mouse_left_down.connect(_on_card_mouse_left_down)
		
		card_view.scale = Vector2.ZERO
		
	return new_cards

func _sort_moving_card(card_view: CardView) -> void:
	var old_index := _card_views.find(card_view)

	_card_views.sort_custom(func(a, b):
		return a.position.x < b.position.x)

	var new_index := _card_views.find(card_view)

	if old_index != new_index:
		_arrange()

# -------------------------
# Handlers
# -------------------------

# -------------
# Game Handlers
# -------------

func _on_game_manager_cards_played(card_data: Array[CardData]) -> void:
	for data in card_data:
		if _card_data.has(data):
			_card_data.erase(data)
			var view := _get_view_by_data(data)
			if _card_views.has(view): _card_views.erase(view)
	_arrange()

func _on_game_manager_cards_drawn(card_data: Array[CardData]) -> void:
	var new_cards = _add_cards(card_data)
	_arrange_new(new_cards)

func _on_game_manager_play_denied(_card_data: Array[CardData]) -> void:
	_arrange()

# -------------
# Card Handlers
# -------------

func _on_card_drag_started(_draggable: Node2D) -> void:
	moving_card = _draggable

func _on_card_drag_ended(_draggable: Node2D) -> void:
	moving_card = null
	_arrange()

func _on_card_drop_zone_entered(draggable: Node2D, _drop_zone: DropZone) -> void:
	if draggable is CardView:
		if _card_views.has(draggable):
			moving_card = null

func _on_card_drop_zone_exited(draggable: Node2D, _drop_zone: DropZone) -> void:
	if draggable is CardView:
		if _card_data.has(draggable.data): 
			moving_card = draggable

func _on_card_mouse_left_down(card_view: CardView) -> void:
	if _selected_cards.has(card_view):
		_selected_cards.erase(card_view)
		card_view.set_selected(false)
		
		for i in range(_selected_cards.size()):
			var card := _selected_cards[i]
			card.set_selected(true, i + 1)
		
	else: 
		_selected_cards.append(card_view)
		card_view.set_selected(true, _selected_cards.size())
	_arrange()

# -------------
# Utilities
# -------------

func _get_view_by_data(data: CardData) -> CardView:
	for view in _card_views: if view.data == data: return view
	return null
