extends Area2D
class_name DropZone

signal drag_component_entered(drag: DragComponent)
signal drag_component_exited(drag: DragComponent)
signal drop_requested(drag: DragComponent)

# -------------------------
# Public API
# -------------------------

func request_drop(draggable: Node2D) -> void:
	emit_signal("drop_requested", draggable)

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
		emit_signal("drag_component_entered", area)

func _on_area_exited(area: Area2D) -> void:
	if area is DragComponent:
		area.unregister_drop_zone(self)
		emit_signal("drag_component_exited", area)
