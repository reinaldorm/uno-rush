extends Node2D
class_name Hand

@export var card_scene : PackedScene
@export var layout_component : LayoutComponent

var _card_data : Array[CardData] = []
var _card_views : Array[CardView] = []
var _dragging_card : CardView = null

# -------------------------
# Public API
# -------------------------

func setup(player_id: int, first_hand: Array[CardView]) -> void:
	set_multiplayer_authority(player_id)

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

	_arrange()

# -------------------------
# Internal
# -------------------------

func _ready() -> void:
	_arrange()
	print(multiplayer.multiplayer_peer)

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
		card_view.mouse_right_down.connect(_on_card_mouse_right_down)

		card_view.scale = Vector2.ZERO

	return new_cards

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
	_dragging_card = null
	_arrange()

func _on_game_manager_cards_drawn(card_data: Array[CardData]) -> void:
	var new_cards = _add_cards(card_data)
	await _arrange_new(new_cards)

func _on_game_manager_play_denied(card_data: Array[CardData]) -> void:
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
	_arrange()

func _on_card_mouse_right_down(card_view: CardView) -> void:
	if is_multiplayer_authority():
		print("Hand: Tried to drag and was the authority: ", card_view.data.id)
		card_view.drag_component.begin_drag()

func _on_card_mouse_left_down(card_view: CardView) -> void:
	print("Hand: Tried to select card: ", card_view.data.id)

# -------------
# Utilities
# -------------

func _get_view_by_data(data: CardData) -> CardView:
	for view in _card_views: if view.data == data: return view
	return null

# -------------
# Debug
# -------------

@export_category("DEV_ENV")
@export var DEV_layout_max_width_overwrite := 300.0
