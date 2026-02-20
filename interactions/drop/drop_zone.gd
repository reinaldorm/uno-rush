extends Area2D
class_name DropZone

signal drag_component_entered(drag: DragComponent)
signal drag_component_exited(drag: DragComponent)

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
	print(area)
	if area is DragComponent:
		area.set_drop_zone(self)
		emit_signal("drag_component_entered", area)

func _on_area_exited(area: Area2D) -> void:
	if area is DragComponent:
		area.set_drop_zone(null)
		emit_signal("drag_component_exited", area)
