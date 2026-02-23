extends Area2D
class_name DragComponent

var dragging := false
var disabled := false
var drop_zone : DropZone = null

signal drag_entered()
signal drag_exited()
signal drag_started(o: Node2D)
signal drag_ended(o: Node2D)
signal drop_zone_entered(draggable: Node2D, drop_zone: DropZone)
signal drop_zone_exited(draggable: Node2D, drop_zone: DropZone)

# -------------------------
# Public API
# -------------------------

func begin_drag() -> void:
	if disabled: return
	owner.z_index = 1000
	dragging = true
	emit_signal("drag_started", owner)

func end_drag() -> void:
	if drop_zone: drop_zone.request_drop(owner)
	drop_zone = null
	owner.z_index = 0
	dragging = false
	emit_signal("drag_ended", owner)

func register_drop_zone(d: DropZone) -> void:
	drop_zone = d
	emit_signal("drop_zone_entered", owner, drop_zone)

func unregister_drop_zone(_d: DropZone) -> void:
	emit_signal("drop_zone_exited", owner, drop_zone)
	drop_zone = null

func disable() -> void:
	disabled = true
 
func restore() -> void:
	pass

# -------------------------
# Internal
# -------------------------

func _process(_delta: float) -> void:
	if dragging:
		owner.global_position = owner.global_position.lerp(get_global_mouse_position(), 0.5)

func _ready() -> void:
	owner = owner as Node2D
