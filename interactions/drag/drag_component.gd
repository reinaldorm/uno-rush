extends Area2D
class_name DragComponent

var dragging := false
var drop_zone : DropZone = null

signal drag_entered()
signal drag_exited()
signal drag_started(o: Node2D)
signal drag_ended(o: Node2D)
signal drop_zone_entered(drop_zone: DropZone)
signal drop_zone_exited(drop_zone: DropZone)

# -------------------------
# Public API
# -------------------------

func begin_drag() -> void:
	owner.z_index = 1000
	dragging = true
	emit_signal("drag_started", owner)

func end_drag() -> void:
	owner.z_index = 0
	dragging = false
	emit_signal("drag_ended", owner)
	
	if drop_zone: drop_zone.request_drop(owner)

func register_drop_zone(d: DropZone) -> void:
	drop_zone = d
	emit_signal("drop_zone_entered", drop_zone)

func unregister_drop_zone(_d: DropZone) -> void:
	emit_signal("drop_zone_exited", drop_zone)
	drop_zone = null

func restore() -> void:
	pass

func disable() -> void:
	monitorable = false
	monitoring = false
	input_pickable = false

# -------------------------
# Internal
# -------------------------

func _input_event(_viewport: Viewport, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.is_action("mouse_left"):
		if event.is_pressed():
			begin_drag()
			_viewport.set_input_as_handled()
		else:
			end_drag()
			_viewport.set_input_as_handled()

func _process(_delta: float) -> void:
	if dragging:
		owner.global_position = owner.global_position.lerp(get_global_mouse_position(), 0.5)

func _ready() -> void:
	owner = owner as Node2D
