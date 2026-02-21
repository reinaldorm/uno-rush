class_name CardView
extends Node2D

@export var sprite_2d : Sprite2D
@export var drag_component : DragComponent

var data : CardData

enum ANIMATION_CHANNEL {
	LAYOUT,
	GRAPHICS
}

var _layout_tween
var _graphics_tween

var _tween_channel : Dictionary<ANIMATION_CHANNEL, Tween> = {
	LAYOUT: null,
	GRAPHICS: null
}

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

func _animate(c: ANIMATION_CHANNEL, kill_previous: bool = true) -> Tween:
	var tween = _tween_channel[c]
	
	if tween: 
		if kill_previous: 
			tween.kill()
			tween = create_tween()
	else: tween = create_tween()

	return tween

func _create_animation_callback(node: Node2D, tween: Tween) -> Callable:
	return func(property: String, value: Variant, duration: float, ease: Tween.EASE, transition: Tween.TRANS) -> void:
		tween.tween_property(node, property, value, duration)
		tween.set_ease(ease)
		tween.set_trans(transition)

func animate_layout(parallel: bool = true, kill_previous: bool = true) -> Callable:
	var tween = _animate(ANIMATION_CHANNEL.LAYOUT, kill_previous)
	tween.set_parallel(parallel)

	return _create_animation_callback(self, tween)

	return animation_callback
 
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
	## Waiting new animation system to be tested
	#if tween: tween.kill()
	#animate_scale(Vector2(2.0, 2.0))
	#rotation = 0.0
	pass

func _on_drag_ended(_o: Node2D) -> void:
	## Waiting new animation system to be tested
	#if tween: tween.kill()
	#animate_scale()
	pass

func _on_drop_zone_entered(_drop_zone: DropZone) -> void:
	## Waiting new animation system to be tested
	#animate_scale()
	pass

func _on_drop_zone_exited(_drop_zone: DropZone) -> void:
	## Waiting new animation system to be tested
	#animate_scale(Vector2(2.0, 2.0))
	pass
