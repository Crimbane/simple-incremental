class_name StateData
extends Resource


var ColorRGB: Color = Color.WHITE
var ColorMultiplier: int = 0
var NextRebirthCost: int = 0
var NextRebirthAvailabilityThreshold: int = 0
var MaxBigShapeLevel: int = 0
var HighestUnlockedShapeButton: int = 0


func _init(data: Dictionary) -> void:
	for key in data:
		if key in self:
			self.set(key, data[key])
