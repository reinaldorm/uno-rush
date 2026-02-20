extends Node2D
class_name DragLayer

# Optional: track active drags (not required, but useful for debugging)
var _active_drags: Array[Node2D] = []

# -------------------------
# Public API
# -------------------------

func begin_drag(item: Node2D) -> void:
	if not is_instance_valid(item):
		return
	
	# Prevent duplicates
	if _active_drags.has(item):
		return
	
	# Store original parent + index (so the item can restore itself later)
	item.set_meta("drag_original_parent", item.get_parent())
	item.set_meta("drag_original_index", item.get_index())
	
	# Reparent to drag layer
	item.reparent(self)
	item.z_index = 1000
	
	_active_drags.append(item)

func end_drag(item: Node2D) -> void:
	if not _active_drags.has(item):
		return
	
	_active_drags.erase(item)
	
	# Visual reset (domain logic decides final parent)
	item.z_index = 0

func restore_to_original_parent(item: Node2D) -> void:
	if not is_instance_valid(item):
		return
	
	var original_parent = item.get_meta("drag_original_parent", null)
	var original_index = item.get_meta("drag_original_index", -1)
	
	if original_parent and is_instance_valid(original_parent):
		item.reparent(original_parent)
		
		if original_index >= 0 and original_index < original_parent.get_child_count():
			original_parent.move_child(item, original_index)
	
	item.z_index = 0
