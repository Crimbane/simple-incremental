class_name ShapeData
extends Resource


var ShapeMultiplier: int = 0
var ShapeCost: int = 0
var BigShapeMultiplier: int = 0
var NextBigShapeCost: int = 0


func _init(data: Dictionary) -> void:
	for key in data:
		if key in self:
			self.set(key, data[key])
