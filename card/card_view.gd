class_name CardView
extends Node2D

signal mouse_left_down(card_view: CardView)
signal mouse_left_up(card_view: CardView)

@export var drag_component : DragComponent

@export var _card_sheet : Sprite2D
@export var _card_sprite : Sprite2D
@export var _back_sprite : Sprite2D

@export var _bubbles_player : AnimationPlayer
@export var _card_player : AnimationPlayer
var _graphics_sprite : Sprite2D

@export var size : Vector2

var data : CardData

var _tween_channels : Dictionary[String, Tween] = { "layout": null, "graphics": null }

# -------------------------
# Public API
# -------------------------

func setup(card_data: CardData, draggable: bool, flipped:= false) -> void:
	data = card_data
	
	_card_sheet.frame_coords = Vector2i(data.number, data.color)
	
	if not draggable: drag_component.queue_free()
	if flipped: set_flip(true)

func animate(channel: String, e:= Tween.EASE_OUT, t:= Tween.TRANS_ELASTIC) -> Tween:
	if _tween_channels[channel]: _tween_channels[channel].kill()
	
	_tween_channels[channel] = create_tween()
	_tween_channels[channel].set_ease(e)
	_tween_channels[channel].set_trans(t)
	
	return _tween_channels[channel]
 
func animate_flip(backwards := false) -> Signal:
	if backwards: _card_player.play_backwards("flip")
	else: _card_player.play("flip")
	return _card_player.animation_finished

func set_flip(backwards := false) -> void:
	var _transform : Transform2D
	if graphics_sprite: 
		graphics_sprite.hide()
		_transforrm = Transform2D(graphics_sprite.transform)
	
	if backwards: 
		_back_sprite.transform = graphics_sprite.transform
		graphics_sprite = _back_sprite
	else: 
		_card_sprite.transform = graphics_sprite.transform
		graphics_sprite = _card_sprite

	if _transform: graphics_sprite.transform = _transform

	graphics_sprite.show()

# -------------------------
# Internal
# -------------------------

# -------------------------
# Handlers
# -------------------------

func _on_drag_started(_o: Node2D) -> void:
	if _tween_channels["layout"]: _tween_channels["layout"].kill()
	var tween = animate("graphics")
	tween.tween_property(_graphics_sprite, "scale", Vector2(2.0, 2.0), 0.4)

func _on_drag_ended(_o: Node2D) -> void:
	var tween = animate("graphics")
	tween.tween_property(_graphics_sprite, "scale", Vector2(2.5, 2.5), 0.4)

func _on_drop_zone_entered(_drop_zone: DropZone) -> void:
	## Waiting new animation system to be tested
	#animate_scale()
	pass

func _on_drop_zone_exited(_drop_zone: DropZone) -> void:
	## Waiting new animation system to be tested
	#animate_scale(Vector2(2.0, 2.0))
	pass

func _on_card_entered() -> void:
	if drag_component and drag_component.dragging: return
	_bubbles_player.play("show_bubbles")
	var tween = animate("graphics")
	
	_graphics_sprite.scale = Vector2(2.25, 2.25)
	_graphics_sprite.rotation = 0.15
	
	tween.set_parallel()
	tween.tween_property(_graphics_sprite, "scale", Vector2(2.5, 2.5), 1.0)
	tween.tween_property(_graphics_sprite, "rotation", 0.0, 1.0)

func _on_card_exited() -> void:
	if drag_component and drag_component.dragging: return
	_bubbles_player.play_backwards("show_bubbles")
	var tween = animate("graphics")
	
	tween.set_parallel()
	tween.tween_property(_graphics_sprite, "scale", Vector2(2.5, 2.5), 0.5)
	tween.tween_property(_graphics_sprite, "rotation", 0.0, 0.5)

func _on_button_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.action_pressed("mouse_left"):
			emit_signal("mouse_left_down", self)
		elif event.action_released("mouse_left"):
			emit_signal("mouse_left_up", self)
		elif event.action_press("mouse_right")
			if drag_component: drag_component.begin_drag()
			_bubbles_player.play_backwards("show_bubbles")
		elif event.action_released("mouse_right")
			if drag_component: drag_component.end_drag()
