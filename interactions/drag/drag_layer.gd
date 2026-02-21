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
	
	# Prevent duplicates
	if _active_drags.has(draggable):
		return
	
	# Store original parent + index (so the draggable can restore itself later)
	draggable.set_meta("drag_original_parent", draggable.get_parent())
	draggable.set_meta("drag_original_index", draggable.get_index())
	
	# Reparent to drag layer
	draggable.reparent(self)
	draggable.z_index = 1000
	
	_active_drags.append(draggable)

func end_drag(draggable: Node2D) -> void:
	if not _active_drags.has(draggable):
		return
	
	_active_drags.erase(draggable)
	
	# Visual reset (domain logic decides final parent)
	draggable.z_index = 0
	restore_to_original_parent(draggable)

func restore_to_original_parent(draggable: Node2D) -> void:
	if not is_instance_valid(draggable):
		return
	
	var original_parent = draggable.get_meta("drag_original_parent", null)
	var original_index = draggable.get_meta("drag_original_index", -1)
	
	if original_parent and is_instance_valid(original_parent):
		original_parent.restore(draggable)
		
		if original_index >= 0 and original_index < original_parent.get_child_count():
			original_parent.move_child(draggable, original_index)
	
	draggable.z_index = 0
