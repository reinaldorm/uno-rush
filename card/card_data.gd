extends Resource
class_name CardData

enum Hue {
	RED,
	GREEN,
	BLUE,
	YELLOW,
	WILD
}

enum Effect {
	DRAW,
	REVERSE,
	SKIP,
	NULL
}

@export var hue : Hue
@export var number : int
@export var effect : Effect
@export var effect_parameter : int
@export var id: String

static func create_numbered(_hue: Hue, _number: int) -> CardData:
	if _number < 0 or _number > 9: pass ## Should throw error as no card may have lower than 0 or greater than 9 numbers.

	var new_data := CardData.new()
	new_data.hue = _hue
	new_data.number = _number
	new_data.effect = Effect.NULL
	new_data.effect_parameter = 0
	new_data.id = new_data.resource_scene_unique_id

	return new_data

static func create_special(_hue: Hue, _effect: Effect, draw_amount:= 0) -> CardData:
	var new_data := CardData.new()
	new_data.hue = _hue
	new_data.number = -1
	new_data.effect = _effect
	new_data.effect_parameter = draw_amount
	new_data.id = new_data.resource_scene_unique_id

	return new_data

static func create_wild(_effect: Effect, draw_amount:= 0) -> CardData:
	var new_data := CardData.new()
	new_data.hue = Hue.WILD
	new_data.number = -1
	new_data.effect = _effect
	new_data.effect_parameter = draw_amount
	new_data.id = new_data.resource_scene_unique_id

	return new_data

static func to_serial(card: CardData) -> Dictionary:
	return {
		"hue": card.hue,
		"number": null,
		"effect": null,
		"effect_parameter": null,
		"id": null
	}

static func to_data(serial: Dictionary) -> CardData:
	var data := CardData.new()

	data.hue ## Todo
	data.number = serial["number"]
	data.effect ## Todo
	data.effect_parameter = serial["effect_parameter"]
	data.id = serial["id"]

	return data
