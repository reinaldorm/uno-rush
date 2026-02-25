extends Area2D
class_name DropZone

signal drag_component_entered(draggable: Node2D)
signal drag_component_exited(draggable: Node2D)
signal drop_requested(draggable: Node2D)
# Intentionally global: valid while only one draggable can be active at a time.
# If concurrent drags/resolutions are added later, listeners will not know which
# draggable this response belongs to and drop outcomes may be misapplied.
signal drop_resolved(response: bool)

# -------------------------
# Public API
# -------------------------

func request_drop(draggable: Node2D) -> Signal:
	emit_signal("drop_requested", draggable)
	return drop_resolved

func resolve_drop(response: bool) -> void:
	emit_signal("drop_resolved", response)
	print("Response at `drop_zone`: ", response)

# -------------------------
# Internal
# -------------------------

func _ready() -> void:
	area_entered.connect(_on_area_entered)
	area_exited.connect(_on_area_exited)

# -------------------------
# Handlers
# -------------------------

func _on_area_entered(area: Area2D) -> void:
	if area is DragComponent:
		area.register_drop_zone(self)
		emit_signal("drag_component_entered", area.owner)

func _on_area_exited(area: Area2D) -> void:
	if area is DragComponent:
		if area.drop_zone == self: area.unregister_drop_zone(self)
		emit_signal("drag_component_exited", area.owner)
