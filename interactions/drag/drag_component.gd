extends Area2D
class_name DragComponent

var dragging := false
var drop_zone : DropZone = null

signal drag_started(o: Control)
signal drag_ended(o: Control)

func begin_drag() -> void:
	dragging = true
	emit_signal("drag_started", owner)

func end_drag() -> void:
	dragging = false
	emit_signal("drag_ended", owner)

func set_drop_zone(d: DropZone) -> void:
	drop_zone = d
	if drop_zone:
		print(drop_zone)

func disable() -> void:
	monitorable = false
	monitoring = false
