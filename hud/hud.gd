extends CanvasLayer
class_name HUD

signal skip_turn()

func _on_skip_turn_pressed() -> void:
	emit_signal("skip_turn")
