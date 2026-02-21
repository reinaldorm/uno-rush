class_name CardView
extends Node2D

@export var sprite_2d : Sprite2D
@export var drag_component : DragComponent

var data : CardData
var tween : Tween

# -------------------------
# Public API
# -------------------------

func setup(card_data: CardData, draggable: bool) -> void:
	data = card_data
	sprite_2d.frame_coords = Vector2i(data.number, data.color)
	if not draggable: drag_component.disable()

func get_size() -> Vector2:
	
	var _size = Vector2(sprite_2d.texture.get_size().x / sprite_2d.hframes, sprite_2d.texture.get_size().y / sprite_2d.vframes)
	
	return _size * 2.5

# Animations

func animate_scale(to: Vector2 = Vector2(2.5, 2.5)) -> void:
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
	if tween: tween.kill()
	tween = create_tween()
	tween.set_ease(e)
	tween.set_trans(t)
	return tween

# -------------------------
# Handlers
# -------------------------

func _on_drag_started(_o: Node2D) -> void:
	if tween: tween.kill()
	animate_scale(Vector2(2.0, 2.0))
	rotation = 0.0

func _on_drag_ended(_o: Node2D) -> void:
	if tween: tween.kill()
	animate_scale()

func _on_drop_zone_entered(_drop_zone: DropZone) -> void:
	animate_scale()

func _on_drop_zone_exited(_drop_zone: DropZone) -> void:
	animate_scale(Vector2(2.0, 2.0))
