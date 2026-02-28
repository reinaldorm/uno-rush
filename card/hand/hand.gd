extends Node2D
class_name Hand

signal selection_changed(card_data: Array[CardData], first_card: CardData)

@export var card_scene : PackedScene
@export var layout_component : HandLayoutComponent

var _card_data : Array[CardData] = []
var _card_views : Array[CardView] = []
var _dragging_card : CardView = null
var selected_cards : Array[CardView] = []

# -------------------------
# Public API
# -------------------------

func start(cards: Array[CardData]) -> void:
	_add_cards(cards)
	_arrange()
	_request_available_cards()

func update_available_cards(available_cards: Array[CardData]) -> void:
	for card in _card_views: card.set_playable(false)
	for data in available_cards:
		var view = _get_view_by_data(data)
		if view: view.set_playable(true)

func restore_card(card_view: CardView) -> void:

	if _card_data.has(card_view.data):
		card_view.reparent(self)

		var _index = card_view.get_meta("drag_original_index")
		_card_views.insert(_index - 1, card_view)
		move_child(card_view, _index)

		card_view.drag_component.drag_started.connect(_on_card_drag_started)
		card_view.mouse_left_down.connect(_on_card_mouse_left_down)

	if card_view == _dragging_card:
		_dragging_card.set_selected(false)
		_dragging_card = null

	selected_cards = []
	_arrange()

# -------------------------
# Internal
# -------------------------

func _ready() -> void:
	if DEV_layout_max_width_overwrite: layout_component.max_arrange_width = DEV_layout_max_width_overwrite
	for child in get_children():
		if child is CardView:
			_card_views.append(child)
			child.set_flip(true)
			#child.setup(CardData.create(randi_range(0, CardData.COLOR.size() - 1), randi_range(0, 9)), false, true)
	_arrange()

func _process(_delta: float) -> void:
	# _sort_dragging_card is not properly handling _dragging_card yet
	# TODO: Fix _sort_dragging_card
	# if _dragging_card: _sort_dragging_card(_dragging_card)
	pass

func _arrange() -> void:
	layout_component.request_arrange(_card_views)

func _arrange_new(cards: Array[CardView]) -> void:
	await layout_component.request_arrange_new(_card_views, cards)
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
		card_view.mouse_left_down.connect(_on_card_mouse_left_down)

		card_view.scale = Vector2.ZERO

	return new_cards

func _select_card(card_view: CardView) -> void:
	if selected_cards.has(card_view):
		selected_cards.erase(card_view)
		card_view.set_selected(false)

		for i in range(selected_cards.size()):
			var card := selected_cards[i]
			card.set_selected(true, i + 1)

	else:
		selected_cards.append(card_view)
		card_view.set_selected(true, selected_cards.size())

	_request_available_cards()
	_arrange()

func _sort_dragging_card(view: CardView) -> void:
	var old_index := _card_views.find(view)

	_card_views.sort_custom(func(a: CardView, b: CardView): return a.position.x < b.position.x)

	var new_index := _card_views.find(view)

	if old_index != new_index: _arrange()

func _request_available_cards() -> void:
	# TODO ------------------------------------------------
	# Guarantee player only see available cards when on turn
	# This may change in the future if off-turn plays be implemented
	# TODO ------------------------------------------------

	if selected_cards.size() > 0:
		var selected_cards_data : Array[CardData] = []
		for card in selected_cards: selected_cards_data.append(card.data)

		emit_signal("selection_changed", selected_cards_data, true)
	else:
		emit_signal("selection_changed", _card_data, false)

# -------------------------
# Handlers
# -------------------------

# -------------
# Game Handlers
# -------------

func _on_game_manager_cards_played(card_data: Array[CardData]) -> void:
	for data in card_data:
		if _card_data.has(data):
			var view := _get_view_by_data(data)
			_card_data.erase(data)
			if _card_views.has(view): _card_views.erase(view)
	selected_cards = []
	_dragging_card = null
	_request_available_cards()
	_arrange()

func _on_game_manager_cards_drawn(card_data: Array[CardData]) -> void:
	var new_cards = _add_cards(card_data)
	await _arrange_new(new_cards)
	selected_cards = []
	_request_available_cards()

func _on_game_manager_play_denied(__card_data: Array[CardData]) -> void:
	_arrange()

# -------------
# Card Handlers
# -------------

func _on_card_drag_started(draggable: Node2D) -> void:
	draggable.drag_component.drag_started.disconnect(_on_card_drag_started)
	draggable.mouse_left_down.disconnect(_on_card_mouse_left_down)

	selected_cards = []
	_select_card(draggable)
	_card_views.erase(draggable)
	_dragging_card = draggable
	_arrange()

func _on_card_drag_ended(_draggable: Node2D) -> void:
	_dragging_card = null
	_arrange()

func _on_card_mouse_left_down(card_view: CardView) -> void:
	_select_card(card_view)

# -------------
# Utilities
# -------------

func _get_view_by_data(data: CardData) -> CardView:
	for view in _card_views: if view.data == data: return view
	return null

# -------------
# Debug
# -------------

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_up"):
		_request_available_cards()

@export_category("DEV_ENV")
@export var DEV_layout_max_width_overwrite := 300.0
