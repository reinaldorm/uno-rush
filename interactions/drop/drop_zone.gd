extends Area2D
class_name DropZone

signal drag_component_entered(draggable: Node2D)
signal drag_component_exited(draggable: Node2D)
signal drop_requested(draggable: Node2D)

signal drop_resolved(response: bool)

# -------------------------
# Public API
# -------------------------

func request_drop(draggable: Node2D) -> bool:
	# Important ordering detail:
	# If `drop_requested` is emitted synchronously here, a listener can call
	# `resolve_drop()` in the same call stack, before this function reaches
	# `await drop_resolved`. That loses the first resolution signal.
	#
	# We defer the request emission so this coroutine is already waiting when
	# game logic eventually resolves the drop.
	call_deferred("_emit_drop_requested", draggable)
	var response = await self.drop_resolved

	if not response:
		print("DropZone: Drop denied, unregistering drop zone")
		draggable.drag_component.unregister_drop_zone(self)

	return response as bool

func resolve_drop(response: bool) -> void:
	emit_signal("drop_resolved", response)

func _emit_drop_requested(draggable: Node2D) -> void:
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
		emit_signal("drag_component_entered", area.owner)

func _on_area_exited(area: Area2D) -> void:
	if area is DragComponent:
		if area.drop_zone == self: area.unregister_drop_zone(self)
		emit_signal("drag_component_exited", area.owner)
