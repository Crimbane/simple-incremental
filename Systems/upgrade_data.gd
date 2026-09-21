class_name UpgradeData
extends Resource


var CurrentLevel: int = 0
var NextLevelCost: int = 0


func _init(data: Dictionary) -> void:
	for key in data:
		if key in self:
			self.set(key, data[key])
