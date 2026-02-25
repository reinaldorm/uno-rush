extends Button;
class_name InputComponent

signal mouse_left_up
signal mouse_left_down
signal mouse_right_up
signal mouse_right_down

var _mouse_down := false

# -------------------------
# Public API
# -------------------------
 
func disable() -> void:
	set_block_signals(true)

func enable() -> void:
	set_block_signals(false)

# -------------------------
# Internal
# -------------------------

func _ready() -> void:
	connect("gui_input", _on_gui_input)

# -------------------------
# Handlers
# -------------------------

func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.is_action_pressed("mouse_left"):
			emit_signal("mouse_left_down")
			_mouse_down = true
		elif event.is_action_released("mouse_left"):
			emit_signal("mouse_left_up")
		elif event.is_action_pressed("mouse_right"):
			emit_signal("mouse_right_down")
			_mouse_down = true
		elif event.is_action_released("mouse_right"):
			emit_signal("mouse_right_up")

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.is_action_released("mouse_left"):
			if _mouse_down:
				emit_signal("mouse_left_up")
				_mouse_down = false
		elif event.is_action_released("mouse_right"):
			if _mouse_down:
				emit_signal("mouse_right_up")
				_mouse_down = false
