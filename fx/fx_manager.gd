extends Node
class_name FXManager

signal camera_shook

@export var fx_layer: Node2D
@export var camera_2d: Camera2D

var _tween_channels = {
	"camera": null
}

# -------------------------
# Public API
# -------------------------

func play_camera_zoom_shake() -> void:
	if not camera_2d:
		return

	var tween = _get_tween("camera").set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT).set_parallel()
	var old_zoom := camera_2d.zoom
	var old_position := camera_2d.position

	camera_2d.zoom = old_zoom * 0.97
	camera_2d.position = old_position * 1.005

	tween.tween_property(camera_2d, "zoom", old_zoom, 1.0)
	tween.tween_property(camera_2d, "position", old_position, 1.0)

	emit_signal("camera_shook")

func play_camera_shake(intensity: float, duration: float) -> void:
	pass

# -------------------------
# Internal
# -------------------------

func _get_tween(channel: String) -> Tween:
	var tween: Tween = _tween_channels.get(channel)
	if tween:
		tween.kill()
	tween = create_tween()
	_tween_channels[channel] = tween

	return tween

# -------------------------
# Handlers
# -------------------------
