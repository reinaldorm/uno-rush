## Hey GPT! I will comment over the code so you can understand the logic behind each code when I created it.

@tool
extends Control
class_name Card

## These are signal that delegates interactions with the card
## The card is just a visual representation of a data so it does not know what to do by its own.
signal card_up(card: Card)
signal card_down(card: Card)
signal card_pressed(card: Card)


## These are merely references to child nodes
@export var sprite_2d : Sprite2D;
## Hold timer is a timer that will set off once a card is pressed and determine by its `timeout` signal
## whether a card were just pressed or held down.
@export var hold_timer : Timer;

## Reference for the card's data
@export var card_data : Dictionary

## Boolean value that tells the card whether it's being
var being_held : bool = false
## The card arrange index inside the hand. This value didn't represent any logic
## when I created it but something felt like I would need it later, tell me if it's necessary!
var arrange_index : int = -1

## A bunch of tweens for each kind of animations I would have and I know having a bunch like this is wrong!
## Please tell a efficient way to manage tween in a way that it does not turn into this hell.
var tween_hover : Tween
var tween_arange : Tween
var tween_rot : Tween
var tween_scale : Tween

## Start is a function that is called by whatever creates a card to setup it before adding it to the scene.
## Q: Is start a standard name for this kind of function or is setup more proper?
func start(card: Dictionary) -> void:
	card_data = Dictionary(card)
	sprite_2d.frame_coords.y  = card_data.color
	sprite_2d.frame_coords.x  = card_data.number

## Animations

## I think I kind got it right by creating a function for animating different aspect of the card 
## but I don't think I got it 100% right since I will still have a lot of tween variables.
func animate_scale(to: Vector2 = Vector2(2.5, 2.5)) -> void:
	if tween_scale: tween_scale.kill()
	tween_scale = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)
	tween_scale.tween_property(sprite_2d, "scale", to, 0.75)

## A function to rotate the card!
func animate_rot(to: float = 0.0) -> void:
	if tween_rot: tween_rot.kill()
	tween_rot = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO)
	tween_rot.tween_property(self, "rotation", to, 0.5)

## Built-in


func _process(_delta: float) -> void:
	## This code functions as a idle animation for the card that only makes it sligtly rotates 
	## using the `ms` variable with the `sin(deg)` function.
	## I know that it must be somewhere separated like in a `idle()` function or something like this but,
	## I will handle that to you.
	var ms = Time.get_ticks_msec()
	sprite_2d.rotation = sin(ms * 0.001) * 0.025

## Handlers

## Cards must react to players actions, one them is to bump a little when the mouse is hovered over then
## and again I know it should be splitted since I doing the same thing when mouse is exited of the card
## so help me understand a good pattern for this.
func _on_mouse_entered() -> void:
	if being_held: return
	if tween_hover: tween_hover.kill()
	tween_hover = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)
	tween_hover.tween_property(sprite_2d, "scale", Vector2(2.75, 2.75), 0.75)

## >:)
func _on_mouse_exited() -> void:
	if being_held: return
	if tween_hover: tween_hover.kill()
	tween_hover = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)
	tween_hover.tween_property(sprite_2d, "scale", Vector2(2.5, 2.5), 0.75)

## Ultimately, the logic behind the validation of the mouse being pressed or held down
## What happens here is basically when the mouse is pressed, a timer set off waiting to understand if
## the press is meant to hold the card of just press it, if the timer times out, it means that the player
## held the card long enough, meaning the desire of hold the card. if the press is too short, later in the code
## the `_on_card_pressed` function will stop the timer making it never timeout, only emitting the code for card press.
func _on_card_down() -> void:
	hold_timer.start()
	await hold_timer.timeout
	being_held = true
	card_down.emit(self)

## Here, card_up is only emitted if the card was being held.
func _on_card_up() -> void:
	if not being_held: return
	else: 
		being_held = false
		card_up.emit(self)

func _on_card_pressed() -> void:
	if not being_held:
		hold_timer.stop()
		card_pressed.emit(self)

## Please help me find a way to make animation look less gross and scalable.
