extends Node2D
class_name DragLayer

# Optional: track active drags (not required, but useful for debugging)
var _active_drags: Array[Node2D] = []

# -------------------------
# Public API
# -------------------------

func begin_drag(draggable: Node2D) -> void:
	if not is_instance_valid(draggable):
		return

	if _active_drags.has(draggable): return
	_active_drags.append(draggable)

	draggable.set_meta("drag_original_parent", draggable.get_parent())
	draggable.set_meta("drag_original_index", draggable.get_index())

	draggable.drag_component.connect("drag_ended", end_drag)

	draggable.reparent(self)
	draggable.z_index = 1000

func end_drag(draggable: Node2D) -> void:
	if not _active_drags.has(draggable): return

	_active_drags.erase(draggable)

	if draggable.drag_component.drop_zone:
		print("Drag component captured drop_zone and trying to drop...")

		# `request_drop()` now returns a boolean result after the zone
		# resolves the request. awaiting it directly keeps the calling code
		# simple and avoids having to manually track or connect to a signal.
		var response: bool = await draggable.drag_component.drop_zone.request_drop(draggable)
		print("After awaiting, `drag_layer` got response=", response)

		# if not response:
		# 	print("Drag component got denied, restoring to parent...")
		# 	restore_to_original_parent(draggable)
		# else:
		# 	print("Drag component got accept, resolve left to `drop_zone` owner.")
	else:
		print("Drag component did not captured drop_zone and was ended.\nRestoring to parent.")
		restore_to_original_parent(draggable)

	draggable.z_index = 0

	draggable.drag_component.disconnect("drag_ended", end_drag)

func restore_to_original_parent(draggable: Node2D) -> void:
	if not is_instance_valid(draggable): return

	var original_parent = draggable.get_meta("drag_original_parent", null)

	if original_parent:
		original_parent.restore_card(draggable)

	draggable.z_index = 0
