extends Resource 
class_name CardData

enum COLOR {
	RED,
	GREEN,
	BLUE,
	YELLOW,
	WILD
}

var color : COLOR
var number : int

static func create(c: COLOR, n: int) -> CardData:
	var new_data := CardData.new()
	new_data.color = c
	new_data.number = n
	
	return new_data
