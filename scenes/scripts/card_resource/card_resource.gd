extends Resource 
class_name CardData

enum COLOR {
	RED,
	GREEN,
	BLUE,
	YELLOW
}

static func create(c: COLOR, n: int) -> Dictionary:
	return {
		"color": c,
		"number": n
	}
