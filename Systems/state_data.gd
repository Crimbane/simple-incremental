class_name StateData
extends Resource


var ColorRGB: Color
var ColorMultiplier: int
var NextRebirthCost: int


func _init(data: Dictionary) -> void:
	for d in data:
		if d in self:
			self.set(d, data[d])
