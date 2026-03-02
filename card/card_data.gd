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
	new_data.id = str(randi_range(0, 1000000))

	return new_data

static func create_special(_hue: Hue, _effect: Effect, draw_amount:= 0) -> CardData:
	var new_data := CardData.new()
	new_data.hue = _hue
	new_data.number = -1
	new_data.effect = _effect
	new_data.effect_parameter = draw_amount
	new_data.id = str(randi_range(0, 1000000))

	return new_data

static func create_wild(_effect: Effect, draw_amount:= 0) -> CardData:
	var new_data := CardData.new()
	new_data.hue = Hue.WILD
	new_data.number = -1
	new_data.effect = _effect
	new_data.effect_parameter = draw_amount
	new_data.id = str(randi_range(0, 1000000))

	return new_data

static func to_serial(card: CardData) -> Dictionary:
	return {
		"hue": card.hue,
		"number": card.number,
		"effect": card.effect,
		"effect_parameter": card.effect_parameter,
		"id": card.id
	}

static func array_to_serial(cards: Array[CardData]) -> Array[Dictionary]:
	var arr : Array[Dictionary] = []

	for card in cards: arr.append(CardData.to_serial(card))

	return arr

static func to_data(serial: Dictionary) -> CardData:
	var data := CardData.new()

	data.hue = serial["hue"]
	data.number = serial["number"]
	data.effect = serial["effect"]
	data.effect_parameter = serial["effect_parameter"]
	data.id = serial["id"]

	return data

static func array_to_data(cards: Array[Dictionary]) -> Array[CardData]:
	var arr : Array[CardData] = []

	for card in cards: arr.append(CardData.to_data(card))

	return arr
