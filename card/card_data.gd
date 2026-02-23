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
	SKIP,
	REVERSE,
	DRAW,
	NULL
}

var hue : Hue
var number : int
var effect : Effect
var effect_parameter : int

static func create_numbered(_hue: Hue, _number: int) -> Category:
	if _number < 0 or _number > 9: pass ## Should throw error as no card may have lower than 0 or greater than 9 numbers.

	var new_data := CardData.new()
	new_data.hue = _hue
	new_data.number = _number
	new_data.effect = null
	new_data.effect_parameter = null

	return new_data

static func create_special(_hue: Hue, _effect: Effect, draw_amount:= 0) -> Category:
	var new_data := CardData.new()
	new_data.hue = _hue
	new_data.number = -1
	new_data.effect = _effect
	new_data.effect_parameter = draw_amount

	return new_data

static func create_wild(_effect: Effect, draw_amount:= 0) -> Category:
	var new_data := CardData.new()
	new_data.hue = Hue.WILD
	new_data.number = -1
	new_data.effect = _effect
	new_data.effect_parameter = draw_amount

	return new_data