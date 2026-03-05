extends Node2D
class_name Hand

@export var card_scene : PackedScene
@export var layout_component : LayoutComponent
@export var selection_component : SelectionComponent
@export var cards_node : Node2D

var _card_views : Array[CardView] = []
var _dragging_card : CardView = null

var player_id : int = -1

# -------------------------
# Public API
# -------------------------

func start() -> void:
	_arrange()

func setup(id: int, first_hand: Array[CardView]) -> void:
	set_multiplayer_authority(id)
	_add_card_views(first_hand)
	player_id = id

func add_cards(card_views: Array[CardView]) -> void:
	_add_card_views(card_views)
	_arrange()

func deselect_all_cards() -> void:
	if not selection_component:
		return
	selection_component.deselect_all()
	_arrange()

func restore_card(card_view: CardView) -> void:

	card_view.reparent(cards_node)

	var _index = card_view.get_meta("drag_original_index")
	_card_views.insert(_index, card_view)
	cards_node.move_child(card_view, _index)

	card_view.drag_component.drag_started.connect(_on_card_drag_started)
	card_view.mouse_left_down.connect(_on_card_mouse_left_down)

	_arrange()

func withdraw_card(card_data: CardData = null) -> CardView:
	var view : CardView = null

	if card_data:
		view = _get_view_by_data(card_data)
		_card_views.erase(view)
	else:
		view = _card_views.pop_back()

	if selection_component and view:
		selection_component.deselect(view)

	_arrange()

	return view

# -------------------------
# Internal
# -------------------------

func _ready() -> void:
	_arrange()

func _arrange() -> void:
	layout_component.request_arrange(_card_views)

func _arrange_new(cards: Array[CardView]) -> void:
	await layout_component.request_arrange_new(_card_views, cards)
	_arrange()

func _add_card_views(card_views: Array[CardView]) -> Array[CardView]:
	var new_cards : Array[CardView] = []

	for view in card_views:
		new_cards.append(view)

		cards_node.add_child(view)
		_card_views.append(view)

		view.set_meta("drag_original_parent", self)

		view.drag_component.drag_started.connect(_on_card_drag_started)
		view.mouse_left_down.connect(_on_card_mouse_left_down)
		view.mouse_right_down.connect(_on_card_mouse_right_down)

		view.scale = Vector2.ZERO

	return new_cards

# -------------------------
# Game Handlers
# -------------------------

func _on_cards_played(_player_id: int) -> void:
	selection_component.deselect_all()

# -------------------------
# Card Handlers
# -------------------------

func _on_card_drag_started(draggable: Node2D) -> void:
	draggable.drag_component.drag_started.disconnect(_on_card_drag_started)
	draggable.mouse_left_down.disconnect(_on_card_mouse_left_down)

	if selection_component and draggable is CardView:
		selection_component.deselect(draggable as CardView)

	_card_views.erase(draggable)
	_arrange()

func _on_card_drag_ended(_draggable: Node2D) -> void:
	_arrange()

func _on_card_mouse_right_down(card_view: CardView) -> void:
	if is_multiplayer_authority():
		card_view.drag_component.begin_drag()

func _on_card_mouse_left_down(card_view: CardView) -> void:
	if is_multiplayer_authority():
		if selection_component:
			selection_component.select(card_view)
	_arrange()

# -------------
# Utilities
# -------------

func _get_view_by_data(data: CardData) -> CardView:
	for view in _card_views:
		if view.data.id == data.id: return view
	return null

# -------------
# Debug
# -------------

@export_category("DEV_ENV")
@export var DEV_layout_max_width_overwrite := 300.0
