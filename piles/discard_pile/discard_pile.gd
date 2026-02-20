@tool
extends Node2D
class_name DiscardPile

@export var warn_text : RichTextLabel
@export var press_hand : Sprite2D
@export var card_scene : PackedScene

var card_pile : Array[CardView] = []

func _ready() -> void:
	var c : CardView = card_scene.instantiate()
	c.setup(CardData.create(CardData.COLOR.RED, 5), false)
	add_child(c)
	
	var t = create_tween()
	t.set_ease(Tween.EASE_IN_OUT)
	t.set_trans(Tween.TRANS_BACK)
	t.set_loops()
	t.tween_property(press_hand, "rotation", -0.25, 0.1)
	t.tween_property(press_hand, "rotation", 0.25, 0.1)

func _process(delta: float) -> void:
	pass

func _on_drop_zone_drag_component_entered(drag: DragComponent) -> void:
	var view : CardView = drag.get_parent()
	view.animate_scale(Vector2(2.5, 2.5))
