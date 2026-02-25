extends Area2D
class_name DropZone

signal drag_component_entered(draggable: Node2D)
signal drag_component_exited(draggable: Node2D)
signal drop_requested(draggable: Node2D)
# Emitted when a drag component requests to be dropped into this zone.
# Listeners should decide whether to accept the drop and call
# `resolve_drop()` with the appropriate boolean.
#
# NOTE: this signal carries *no response channel*. previously the API
# returned the `drop_resolved` signal object so callers could await it;
# that exposed a global, shared signal and made the contract opaque.
# Concurrency (multiple drags) would result in multiple waiters being
# awakened by a single resolution. See `request_drop()` for the new
# contract.

signal drop_resolved(response: bool)

# -------------------------
# Public API
# -------------------------

func request_drop(draggable: Node2D) -> bool:
	# Ask the zone whether the given `draggable` may be dropped here.

	# This method emits `drop_requested` and then *awaits* the next
	# `drop_resolved` signal from **this instance**. Callers should use it
	# like the following:

	# var ok: bool = await zone.request_drop(draggable)

	# The returned state resolves to the boolean response. Returning an
	# awaitable (rather than the raw signal) makes the API self-documenting
	# and prevents external code from accidentally awaiting the wrong
	# signal. It also avoids the previous pitfall where two concurrent
	# draggables would share a single `drop_resolved` signal object and
	# both be resumed by the first resolution.

	emit_signal("drop_requested", draggable)
	# waiting here creates a fresh, per-call awaitable that unwraps the
	# boolean; it automatically filters out any earlier emissions.
	var response = await self.drop_resolved
	return response as bool

func resolve_drop(response: bool) -> void:
	# Inform any awaiting caller of the drop decision.

	# Because `request_drop()` now awaits the signal internally, callers
	# receive the value directly and there is no need to return the signal
	# object. This method is typically invoked by whatever logic handles
	# `drop_requested` (e.g. a game manager or the zone's owner).
	emit_signal("drop_resolved", response)
	# debugging aid only; remove or guard in non-debug builds if it
	# becomes noisy.
	if Engine.is_editor_hint():
		print_debug("DropZone response: %s" % response)

# -------------------------
# Internal
# -------------------------

func _ready() -> void:
	# connect explicitly by name so that the script can be attached to a
	# different node type without silently failing; keeps the API clear.
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
