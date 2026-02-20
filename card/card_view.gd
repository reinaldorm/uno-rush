class_name CardView
extends Node2D

@export var sprite_2d : Sprite2D
@export var hold_timer : Timer
@export var drag_component : DragComponent


## As result of reparenting a node, 
var ignore_next_mouse_handle := true
var draggable := false

var data : CardData
var tween : Tween

# -------------------------
# Public API
# -------------------------

func setup(card_data: CardData, d: bool) -> void:
	data = card_data
	sprite_2d.frame_coords = Vector2i(data.number, data.color)
	draggable = d
	if not draggable: drag_component.disable()

# Animations

func animate_scale(to: Vector2) -> void:
	var t = _new_tween()
	t.tween_property(sprite_2d, "scale", to, 0.75)

func animate_rotation(to: float) -> void:
	var t = _new_tween(Tween.EASE_OUT, Tween.TRANS_EXPO)
	t.tween_property(self, "rotation", to, 0.3)

func animate_to(pos: Vector2, rot: float) -> void:
	var t = _new_tween()
	t.set_parallel()
	t.tween_property(self, "position", pos, 0.75)
	t.tween_property(self, "rotation", rot, 0.75)
	t.tween_property(sprite_2d, "scale", Vector2(2.5, 2.5), 0.75)

# -------------------------
# Internal
# -------------------------

func _set_hovered(value: bool) -> void:
	if drag_component.being_dragged: return
	
	var target_scale := Vector2(2.75, 2.75) if value else Vector2(2.5, 2.5)
	animate_scale(target_scale)

func _new_tween(e := Tween.EASE_OUT, t := Tween.TRANS_ELASTIC) -> Tween:
	if tween:
		tween.kill()
	tween = create_tween()
	tween.set_ease(e)
	tween.set_trans(t)
	return tween

func _process(_delta: float) -> void:
	if drag_component.dragging:
		global_position = get_global_mouse_position()
		pass
	pass

# -------------------------
# Handlers
# -------------------------

func _on_button_down() -> void:
	if not draggable: return
	tween.kill()
	drag_component.begin_drag()
	animate_scale(Vector2(2.25, 2.25))

func _on_button_up() -> void:
	if not draggable: return
	if ignore_next_mouse_handle: 
		return
	drag_component.end_drag()

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.is_action_released("mouse_left"):
		if drag_component.dragging and ignore_next_mouse_handle:
			drag_component.end_drag()
			ignore_next_mouse_handle = false
			print("should print")
