class_name StateData
extends Resource


var ColorRGB: Color
var ColorMultiplier: int
var NextRebirthCost: int


func _init(data: Dictionary) -> void:
	for key in data:
		if key in self:
			self.set(key, data[key])
