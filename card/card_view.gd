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

func _get_tween_by_channel(c: ANIMATION_CHANNEL, kill_previous: bool = true) -> Tween:
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

func animate(channel: ANIMATION_CHANNEL, parallel: bool = true, kill_previous: bool = true) -> Callable:
	var tween = _get_tween_by_channel(ANIMATION_CHANNEL, kill_previous)
	tween.set_parallel(parallel)

	var to_animate: Node2D

	match channel:
		ANIMATION.CHANNEL.LAYOUT:
			to_animate = self
		ANIMATION.CHANNEL.GRAPHICS:
			to_animate = sprite_2d

	return _create_animation_callback(to_animate, tween)
 
# -------------------------
# Internal
# -------------------------

func _set_hovered(value: bool) -> void:
	## Waiting new animation system to be tested
	pass

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
