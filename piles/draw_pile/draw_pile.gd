extends Node2D
class_name DrawPile

signal draw_requested()

@export var card_scene: PackedScene

@export var top_card_sprite: Sprite2D
@export var pile_card_sprite: Sprite2D
@export var animation_player: AnimationPlayer

var _tween: Tween

# -------------------------
# Public API
# -------------------------

func draw_cards(card_data: Array[CardData]) -> void:
	for data in card_data:
		var view : CardView = card_scene.instantiate()
		view.setup(data, false)
		add_child(view)

# -------------------------
# Internal
# -------------------------

func _animate_entered() -> void:
	var tween := _new_tween()
	
	tween.set_parallel()
	tween.tween_property(top_card_sprite, "position:y", -15, 0.5)
	_tween.tween_method(func(value: float):
		top_card_sprite.material.set_shader_parameter("x_rot", value),
		top_card_sprite.material.get_shader_parameter("x_rot"),
		0.0,
		0.5)

func _animate_exited() -> void:
	var tween := _new_tween()
	
	tween.set_parallel()
	tween.tween_property(top_card_sprite, "position:y", 0, 0.5)
	_tween.tween_method(func(value: float):
		top_card_sprite.material.set_shader_parameter("x_rot", value),
		top_card_sprite.material.get_shader_parameter("x_rot"),
		7.5,
		0.5)

func _new_tween(e:= Tween.EASE_OUT, t:= Tween.TransitionType.TRANS_EXPO) -> Tween:
	if _tween: _tween.kill()

	_tween = create_tween()
	_tween.set_ease(e)
	_tween.set_trans(t)
	
	return _tween

# -------------------------
# Handlers
# -------------------------

func _on_button_mouse_entered() -> void:
	animation_player.play("hover")

func _on_button_mouse_exited() -> void:
	animation_player.play_backwards("hover")

func _on_button_pressed() -> void:
	emit_signal("draw_requested")
