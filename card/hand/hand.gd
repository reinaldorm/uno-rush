extends Node2D
class_name Hand

signal selection_changed(card_data: Array[CardData], first_card: CardData)

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

	_arrange()

# -------------------------
# Internal
# -------------------------

func _ready() -> void:
	if DEV_layout_max_width_overwrite: layout_component.max_arrange_width = DEV_layout_max_width_overwrite
	for child in get_children():
		if child is CardView:
			_card_views.append(child)
			#child.setup(CardData.create(randi_range(0, CardData.COLOR.size() - 1), randi_range(0, 9)), false, true)
	_arrange()

func _process(_delta: float) -> void:
	if moving_card: _sort_moving_card(moving_card)

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
	if _selected_cards.has(card_view):
		_selected_cards.erase(card_view)
		card_view.set_selected(false)

		for i in range(_selected_cards.size()):
			var card := _selected_cards[i]
			card.set_selected(true, i + 1)

	else:
		_selected_cards.append(card_view)
		card_view.set_selected(true, _selected_cards.size())

	_request_available_cards()

func _sort_moving_card(view: CardView) -> void:
	var old_index := _card_views.find(view)

	_card_views.sort_custom(func(a: CardView, b: CardView): return a.position.x < b.position.x)

	var new_index := _card_views.find(view)

	if old_index != new_index: _arrange()

func _request_available_cards() -> void:
	# TODO ------------------------------------------------
	# Guarantee player only see available cards when on turn
	# This may change in the future if off-turn plays be implemented
	# TODO ------------------------------------------------

	if _selected_cards.size():
		emit_signal("selection_changed", _card_data, _selected_cards[0].data)
	else:
		emit_signal("selection_changed", _card_data, null)

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
	_selected_cards = []
	_request_available_cards()
	_arrange()

func _on_game_manager_cards_drawn(card_data: Array[CardData]) -> void:
	var new_cards = _add_cards(card_data)
	await _arrange_new(new_cards)
	_selected_cards = []
	_request_available_cards()

func _on_game_manager_play_denied(__card_data: Array[CardData]) -> void:
	_arrange()

# -------------
# Card Handlers
# -------------

func _on_card_drag_started(draggable: Node2D) -> void:
	draggable.drag_component.drag_started.disconnect(_on_card_drag_started)
	draggable.mouse_left_down.disconnect(_on_card_mouse_left_down)
	_card_views.erase(draggable)
	_arrange()

func _on_card_drag_ended(_draggable: Node2D) -> void:
	moving_card = null
	_arrange()

func _on_card_mouse_left_down(card_view: CardView) -> void:
	_select_card(card_view)
	_arrange()

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
