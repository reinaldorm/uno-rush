class_name AttachComponent
extends Button

signal card_entered
signal card_exited
signal card_dropped(card: Card)

func _ready() -> void:
	mouse_entered.connect(_on_attach_area_entered)
	mouse_exited.connect(_on_attach_area_exited)

func _on_attach_area_entered() -> void:
	if CardManager.held_card: card_entered.emit()

func _on_attach_area_exited() -> void:
	if CardManager.held_card: card_exited.emit()
