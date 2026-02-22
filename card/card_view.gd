class_name CardView
extends Node2D

@export var drag_component : DragComponent

@export var sprite_2d : Sprite2D
@export var animation_player : AnimationPlayer

var data : CardData

var _tween_channels : Dictionary[String, Tween] = {
	"layout": null,
	"graphics": null,
}

# -------------------------
# Public API
# -------------------------

func setup(card_data: CardData, draggable: bool) -> void:
	data = card_data
	sprite_2d.frame_coords = Vector2i(data.number, data.color)
	if not draggable: drag_component.queue_free()

func get_size() -> Vector2:
	var _size = Vector2(sprite_2d.texture.get_size().x / sprite_2d.hframes, sprite_2d.texture.get_size().y / sprite_2d.vframes)
	
	return _size * 2.5

func animate(channel: String, e:= Tween.EASE_OUT, t:= Tween.TRANS_ELASTIC) -> Tween:
	if _tween_channels[channel]: _tween_channels[channel].kill()
	
	_tween_channels[channel] = create_tween()
	_tween_channels[channel].set_ease(e)
	_tween_channels[channel].set_trans(t)
	
	return _tween_channels[channel]
 
# -------------------------
# Internal
# -------------------------

# -------------------------
# Handlers
# -------------------------

func _on_drag_started(_o: Node2D) -> void:
	if _tween_channels["layout"]: _tween_channels["layout"].kill()
	var tween = animate("graphics")
	tween.tween_property(sprite_2d, "scale", Vector2(2.0, 2.0), 0.4)

func _on_drag_ended(_o: Node2D) -> void:
	var tween = animate("graphics")
	tween.tween_property(sprite_2d, "scale", Vector2(2.5, 2.5), 0.4)

func _on_drop_zone_entered(_drop_zone: DropZone) -> void:
	## Waiting new animation system to be tested
	#animate_scale()
	pass

func _on_drop_zone_exited(_drop_zone: DropZone) -> void:
	## Waiting new animation system to be tested
	#animate_scale(Vector2(2.0, 2.0))
	pass

func _on_card_down() -> void:
	animation_player.play_backwards("show_bubbles")
	if drag_component: drag_component.begin_drag()

func _on_card_up() -> void:
	if drag_component: drag_component.end_drag()

func _on_card_entered() -> void:
	if drag_component and drag_component.dragging: return
	animation_player.play("show_bubbles")
	var tween = animate("graphics")
	
	sprite_2d.scale = Vector2(2.25, 2.25)
	sprite_2d.rotation = 0.15
	
	tween.set_parallel()
	tween.tween_property(sprite_2d, "scale", Vector2(2.5, 2.5), 1.0)
	tween.tween_property(sprite_2d, "rotation", 0.0, 1.0)

func _on_card_exited() -> void:
	if drag_component and drag_component.dragging: return
	animation_player.play_backwards("show_bubbles")
	var tween = animate("graphics")
	
	tween.set_parallel()
	tween.tween_property(sprite_2d, "scale", Vector2(2.5, 2.5), 0.5)
	tween.tween_property(sprite_2d, "rotation", 0.0, 0.5)
