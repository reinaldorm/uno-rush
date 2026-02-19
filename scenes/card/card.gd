@tool
extends Control
class_name Card

signal card_up(card: Card)
signal card_down(card: Card)
signal card_pressed(card: Card)

@export var sprite_2d : Sprite2D;
@export var hold_timer : Timer;

@export var card_data : Dictionary

var being_held : bool = false
var arrange_index : int = -1

var tween_hover : Tween
var tween_arange : Tween
var tween_rot : Tween
var tween_scale : Tween

func start(card: Dictionary) -> void:
	card_data = Dictionary(card)
	sprite_2d.frame_coords.y  = card_data.color
	sprite_2d.frame_coords.x  = card_data.number

## Animations

func animate_scale(to: Vector2 = Vector2(2.5, 2.5)) -> void:
	if tween_scale: tween_scale.kill()
	tween_scale = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)
	tween_scale.tween_property(sprite_2d, "scale", to, 0.75)

func animate_rot(to: float = 0.0) -> void:
	if tween_rot: tween_rot.kill()
	tween_rot = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO)
	tween_rot.tween_property(self, "rotation", to, 0.5)

## Built-in

func _process(_delta: float) -> void:
	var ms = Time.get_ticks_msec()
	sprite_2d.rotation = sin(ms * 0.001) * 0.025

## Handlers

func _on_mouse_entered() -> void:
	if being_held: return
	if tween_hover: tween_hover.kill()
	tween_hover = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)
	tween_hover.tween_property(sprite_2d, "scale", Vector2(2.75, 2.75), 0.75)

func _on_mouse_exited() -> void:
	if being_held: return
	if tween_hover: tween_hover.kill()
	tween_hover = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)
	tween_hover.tween_property(sprite_2d, "scale", Vector2(2.5, 2.5), 0.75)

func _on_card_down() -> void:
	hold_timer.start()
	await hold_timer.timeout
	being_held = true
	card_down.emit(self)

func _on_card_up() -> void:
	if not being_held: return
	else: 
		being_held = false
		card_up.emit(self)

func _on_card_pressed() -> void:
	if not being_held:
		hold_timer.stop()
		card_pressed.emit(self)
