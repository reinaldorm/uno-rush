extends Area2D
class_name DragComponent

var dragging := false
var disabled := false
var drop_zone : DropZone = null

signal drag_started(draggable: Node2D)
signal drag_ended(draggable: Node2D)
signal drop_zone_entered(draggable: Node2D, drop_zone: DropZone)
signal drop_zone_exited(draggable: Node2D, drop_zone: DropZone)

# -------------------------
# Public API
# --------------------																	-----

func begin_drag() -> void:
	dragging = true
	emit_signal("drag_started", owner)
	get_tree().call_group("drag_layer", "begin_drag", owner)

func end_drag() -> void:
	if not dragging: return

	dragging = false
	emit_signal("drag_ended", owner)

func register_drop_zone(d: DropZone) -> void:
	drop_zone = d
	emit_signal("drop_zone_entered", owner, drop_zone)

func unregister_drop_zone(_d: DropZone) -> void:
	emit_signal("drop_zone_exited", owner, drop_zone)
	drop_zone = null

# -------------------------
# Internal
# -------------------------

func _process(_delta: float) -> void:
	if dragging:
		owner.global_position = owner.global_position.lerp(get_global_mouse_position(), 0.5)

func _ready() -> void:
	owner = owner as Node2D
