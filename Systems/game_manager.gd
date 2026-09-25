extends Node


const BASE_GRID_SIZE: int = 2
const BASE_INCREMENT_AMOUNT: int = 0
const BASE_INTERVAL: float = 1.0
const BASE_SHAPE_SYNERGY_MULTI: float = 0.2

enum NotationStyle { NONE, ABBREVIATION, SCIENTIFIC, ENGINEERING }
var notationStyle: NotationStyle = NotationStyle.ABBREVIATION

var money: int = 1000000000000
var time: float = 0.0
var interval: float = BASE_INTERVAL # Seconds between increments
var incrementAmount: int = BASE_INCREMENT_AMOUNT
var synergyUnlocked: bool = false
var synergyMulti: float = BASE_SHAPE_SYNERGY_MULTI
var highestUnlockedShapeButton: int = 7
var gridSize: int = BASE_GRID_SIZE:
	set(value):
		gridSize = value
		if UIManager:
			UIManager.updateGrid()

#region Dictionary
enum State { White, Red, Orange, Yellow, Green, Blue, Purple, Black }
var StateInfo: Dictionary[State, StateData] = {
	State.White: StateData.new({
		ColorRGB = Color(0.9, 0.9, 0.9),
		ColorMultiplier = 1,
		NextRebirthCost = 100,
		NextRebirthAvailabilityThreshold = 100,
		MaxBigShapeLevel = 9
	}),
	State.Red: StateData.new({
		ColorRGB = Color(0.8, 0.2, 0.2),
		ColorMultiplier = 2,
		NextRebirthCost = 200,
		NextRebirthAvailabilityThreshold = 200,
		MaxBigShapeLevel = 9
	}),
	State.Orange: StateData.new({
		ColorRGB = Color(1.0, 0.5, 0.0),
		ColorMultiplier = 4,
		NextRebirthCost = 300,
		NextRebirthAvailabilityThreshold = 300,
		MaxBigShapeLevel = 9
	}),
	State.Yellow: StateData.new({
		ColorRGB = Color(1.0, 0.8, 0.0),
		ColorMultiplier = 8,
		NextRebirthCost = 400,
		NextRebirthAvailabilityThreshold = 400,
		MaxBigShapeLevel = 9
	}),
	State.Green: StateData.new({
		ColorRGB = Color(0.2, 0.7, 0.2),
		ColorMultiplier = 16,
		NextRebirthCost = 500,
		NextRebirthAvailabilityThreshold = 500,
		MaxBigShapeLevel = 9
	}),
	State.Blue: StateData.new({
		ColorRGB = Color(0.4, 0.5, 0.8),
		ColorMultiplier = 32,
		NextRebirthCost = 600,
		NextRebirthAvailabilityThreshold = 600,
		MaxBigShapeLevel = 9
	}),
	State.Purple: StateData.new({
		ColorRGB = Color(0.8, 0.2, 0.9),
		ColorMultiplier = 64,
		NextRebirthCost = 700,
		NextRebirthAvailabilityThreshold = 700,
		MaxBigShapeLevel = 9
	}),
	State.Black: StateData.new({
		ColorRGB = Color(0.1, 0.1, 0.1),
		ColorMultiplier = 128,
		MaxBigShapeLevel = 10
	})
}
var currentState: int = State.White

enum ShapeType { Dot, Line, Triangle, Square, Pentagon, Hexagon, Heptagon, Octagon, Nonagon, Decagon, Circle }
var ShapeInfo: Dictionary[ShapeType, ShapeData] = {
	ShapeType.Dot: ShapeData.new({
		ShapeMultiplier = 1,
		ShapeCost = 10,
		BigShapeMultiplier = 1,
		NextBigShapeCost = 100
	}),
	ShapeType.Line: ShapeData.new({
		ShapeMultiplier = 2,
		ShapeCost = 20,
		BigShapeMultiplier = 2,
		NextBigShapeCost = 200
	}),
	ShapeType.Triangle: ShapeData.new({
		ShapeMultiplier = 3,
		ShapeCost = 30,
		BigShapeMultiplier = 3,
		NextBigShapeCost = 300
	}),
	ShapeType.Square: ShapeData.new({
		ShapeMultiplier = 4,
		ShapeCost = 40,
		BigShapeMultiplier = 4,
		NextBigShapeCost = 400
	}),
	ShapeType.Pentagon: ShapeData.new({
		ShapeMultiplier = 5,
		ShapeCost = 50,
		BigShapeMultiplier = 5,
		NextBigShapeCost = 500
	}),
	ShapeType.Hexagon: ShapeData.new({
		ShapeMultiplier = 6,
		ShapeCost = 60,
		BigShapeMultiplier = 6,
		NextBigShapeCost = 600
	}),
	ShapeType.Heptagon: ShapeData.new({
		ShapeMultiplier = 7,
		ShapeCost = 70,
		BigShapeMultiplier = 7,
		NextBigShapeCost = 700
	}),
	ShapeType.Octagon: ShapeData.new({
		ShapeMultiplier = 8,
		ShapeCost = 80,
		BigShapeMultiplier = 8,
		NextBigShapeCost = 800
	}),
	ShapeType.Nonagon: ShapeData.new({
		BigShapeMultiplier = 9,
		NextBigShapeCost = 900
	}),
	ShapeType.Decagon: ShapeData.new({
		BigShapeMultiplier = 10,
		NextBigShapeCost = 10*18 # 1 Quintillion / 1.0e18
	})
}
var currentBigShapeType: int = ShapeType.Dot

enum UpgradeType { Interval, Grid, SynergyUnlock, SynergyMulti }
var UpgradeInfo: Dictionary[UpgradeType, UpgradeData] = {
	UpgradeType.Interval: UpgradeData.new({
		CurrentLevel = 0,
		MaxLevel = 10,
		BaseCost = 100,
		NextLevelCost = 100,
		ExponentialCostIncrease = 10
	}),
	UpgradeType.Grid: UpgradeData.new({
		CurrentLevel = 0,
		MaxLevel = 6,
		BaseCost = 100,
		NextLevelCost = 100,
		ExponentialCostIncrease = 8
	}),
	UpgradeType.SynergyUnlock: UpgradeData.new({
		CurrentLevel = 0,
		MaxLevel = 1,
		BaseCost = 100,
		NextLevelCost = 100,
		ExponentialCostIncrease = 5
	}),
	UpgradeType.SynergyMulti: UpgradeData.new({
		CurrentLevel = 0,
		MaxLevel = 4,
		BaseCost = 100,
		NextLevelCost = 100,
		ExponentialCostIncrease = 8
	}),
}
#endregion



var gridStorage: Array[Dictionary]


var UIManager: Node = null
var bigShape: Node2D = null
var upgraded = false

func _ready() -> void:
	pass # Replace with function body.


func _process(delta: float) -> void:
	time += delta
	
	if time > interval:
		time = 0
		money += incrementAmount


#region Money
func addMoney(amount: int) -> void:
	money += amount


func removeMoney(amount: int) -> void:
	money -= amount


func calculateMoneyIncrement() -> void:
	incrementAmount = BASE_INCREMENT_AMOUNT
	for dict in gridStorage:
		var shape = dict["shape"].shapeSprite
		var shapeValue = ShapeInfo[dict["shape"].shapeSprite].ShapeMultiplier
		var shapeSynergy = getShapeSynergyMulti(shape)
		
		var finalShapeValue = shapeValue * shapeSynergy
		
		incrementAmount += roundi(finalShapeValue)
	
	if currentBigShapeType != ShapeType.Circle:
		incrementAmount *= ShapeInfo[currentBigShapeType].BigShapeMultiplier
	
	incrementAmount *= StateInfo[currentState].ColorMultiplier
	print("incrementAmount: ", incrementAmount)


func getShapeCost(baseCost: int, shape: Shape.ShapeSprite) -> int:
	var count: int = getShapeCount(shape)
	
	return roundi(baseCost * pow(1.15, count))


func getShapeSynergyMulti(shape: Shape.ShapeSprite) -> float:
	if synergyUnlocked:
		var count: int = getShapeCount(shape - 4)
		
		var multiplier = 1.0 + (count * synergyMulti)
		print("getShapeSynergyMulti", synergyMulti)
		print("multiplier: ", multiplier)
		
		return multiplier
	else:
		return 1.0
	

#endregion


#region Upgrades
func rebirth() -> void:
	if currentState == State.Black:
		return
	if money < StateInfo[currentState].NextRebirthCost:
		print("Not enough money")
		return
	
	removeMoney(StateInfo[currentState].NextRebirthCost)
	
	currentState += 1
	
	await UIManager.createPreRebirthScreenshot()
	
	bigShape.updateColor()
	UIManager.updateColor()
	UIManager.clearShapesInGrid()
	clearStorage()
	clearUpgrades()
	calculateMoneyIncrement()
	
	UIManager.playRebirthTransition(StateInfo[currentState].ColorRGB)


func upgradeBigShape() -> void:
	var currentLevel: int = currentBigShapeType
	
	if currentBigShapeType == ShapeType.Circle:
		print("bigshape max level reached")
		return
	if currentLevel == StateInfo[currentState].MaxBigShapeLevel:
		print("current level == max level")
		return
	var cost: int = ShapeInfo[currentBigShapeType].NextBigShapeCost
	
	if money < cost:
		print("Not enough money")
		return
	
	removeMoney(cost)
	
	currentBigShapeType += 1
	
	bigShape.updateSprite()
	
	print("upgraded big shape to ", ShapeType.find_key(currentBigShapeType))
	calculateMoneyIncrement()

func upgradeMoneyInterval() -> void:
	var cost: int = UpgradeInfo[UpgradeType.Interval].NextLevelCost
	var baseCost: int = UpgradeInfo[UpgradeType.Interval].BaseCost
	var costIncrease: float = UpgradeInfo[UpgradeType.Interval].ExponentialCostIncrease
	var currentLevel: int = UpgradeInfo[UpgradeType.Interval].CurrentLevel
	
	if interval <= 0.1 or currentLevel == UpgradeInfo[UpgradeType.Interval].MaxLevel:
		UpgradeInfo[UpgradeType.Interval].NextLevelCost = 0
		return
	
	if money < cost:
		print("Not enough money")
		return
	removeMoney(cost)
	
	currentLevel += 1
	UpgradeInfo[UpgradeType.Interval].CurrentLevel = currentLevel
	
	var nextLevelCost = roundi(baseCost * pow(costIncrease, currentLevel))
	UpgradeInfo[UpgradeType.Interval].NextLevelCost = nextLevelCost
	
	interval -= 0.09

func upgradeGrid() -> void:
	var cost: int = UpgradeInfo[UpgradeType.Grid].NextLevelCost
	var baseCost: int = UpgradeInfo[UpgradeType.Grid].BaseCost
	var costIncrease: float = UpgradeInfo[UpgradeType.Grid].ExponentialCostIncrease
	var currentLevel: int = UpgradeInfo[UpgradeType.Grid].CurrentLevel
	
	if gridSize == 8 or currentLevel == UpgradeInfo[UpgradeType.Grid].MaxLevel:
		UpgradeInfo[UpgradeType.Grid].NextLevelCost = 0
		return
	
	if money < cost:
		print("Not enough money")
		return
	removeMoney(cost)
	
	currentLevel += 1
	UpgradeInfo[UpgradeType.Grid].CurrentLevel = currentLevel
	
	var nextLevelCost = roundi(baseCost * pow(costIncrease, currentLevel))
	UpgradeInfo[UpgradeType.Grid].NextLevelCost = nextLevelCost
	
	gridSize += 1


func upgradeSynergyUnlock() -> void:
	var cost: int = UpgradeInfo[UpgradeType.SynergyUnlock].NextLevelCost
	var baseCost: int = UpgradeInfo[UpgradeType.SynergyUnlock].BaseCost
	var costIncrease: float = UpgradeInfo[UpgradeType.SynergyUnlock].ExponentialCostIncrease
	var currentLevel: int = UpgradeInfo[UpgradeType.SynergyUnlock].CurrentLevel
	
	if synergyUnlocked == true or currentLevel == UpgradeInfo[UpgradeType.SynergyUnlock].MaxLevel:
		UpgradeInfo[UpgradeType.SynergyUnlock].NextLevelCost = 0
		return
	
	if money < cost:
		print("Not enough money")
		return
	removeMoney(cost)
	
	currentLevel += 1
	UpgradeInfo[UpgradeType.SynergyUnlock].CurrentLevel = currentLevel
	
	var nextLevelCost = roundi(baseCost * pow(costIncrease, currentLevel))
	UpgradeInfo[UpgradeType.SynergyUnlock].NextLevelCost = nextLevelCost
	
	synergyUnlocked = true


func upgradeSynergyMultiplier() -> void:
	var cost: int = UpgradeInfo[UpgradeType.SynergyMulti].NextLevelCost
	var baseCost: int = UpgradeInfo[UpgradeType.SynergyMulti].BaseCost
	var costIncrease: float = UpgradeInfo[UpgradeType.SynergyMulti].ExponentialCostIncrease
	var currentLevel: int = UpgradeInfo[UpgradeType.SynergyMulti].CurrentLevel
	
	if currentLevel == UpgradeInfo[UpgradeType.SynergyMulti].MaxLevel:
		UpgradeInfo[UpgradeType.SynergyMulti].NextLevelCost = 0
		return
	
	if money < cost:
		print("Not enough money")
		return
	removeMoney(cost)
	
	currentLevel += 1
	UpgradeInfo[UpgradeType.SynergyMulti].CurrentLevel = currentLevel
	
	var nextLevelCost = roundi(baseCost * pow(costIncrease, currentLevel))
	UpgradeInfo[UpgradeType.SynergyMulti].NextLevelCost = nextLevelCost
	
	synergyMulti += 0.1


func clearUpgrades() -> void:
	gridSize = BASE_GRID_SIZE
	UpgradeInfo[UpgradeType.Grid].CurrentLevel = 0
	UpgradeInfo[UpgradeType.Grid].NextLevelCost = UpgradeInfo[UpgradeType.Grid].BaseCost
	
	interval = BASE_INTERVAL
	UpgradeInfo[UpgradeType.Interval].CurrentLevel = 0
	UpgradeInfo[UpgradeType.Interval].NextLevelCost = UpgradeInfo[UpgradeType.Interval].BaseCost
	
	currentBigShapeType = ShapeType.Dot
	bigShape.updateSprite()
	
	highestUnlockedShapeButton = 0
	UIManager.shapeButtons.propagate_call("updateVisibility")

#endregion


func unlockNextShapeButton(shape: int) -> void:
	if shape > highestUnlockedShapeButton:
		highestUnlockedShapeButton += 1
		print(highestUnlockedShapeButton)
		for button in UIManager.shapeButtons.get_children():
			if button.shapeSprite == shape:
				button.updateVisibility()




#region Grid
func addShapeToStorage(slot: int, shape: Node2D, storage: Array[Dictionary] = gridStorage) -> void:
	storage.append({"slot": slot,"shape": shape})


func removeShapeFromStorage(shape: Node2D, storage: Array[Dictionary] = gridStorage) -> void:
	for dict in storage:
		if dict["shape"] == shape:
			storage.erase(dict)
			return


func removeShapeFromStorageSlot(slot: int, storage: Array[Dictionary] = gridStorage) -> void:
	for dict in storage:
		if dict["slot"] == slot:
			storage.erase(dict)
			return


func getShapeInStorageBySlot(slot: int, storage: Array[Dictionary] = gridStorage) -> Node2D:
	for dict in storage:
		if dict["slot"] == slot:
			return dict["shape"]
	return null


func getSlotInStorageByShape(shape: Node2D, storage: Array[Dictionary] = gridStorage):
	for dict in storage:
		if dict["shape"] == shape:
			return dict["slot"]
	return null


func clearStorage(storage: Array[Dictionary] = gridStorage) -> void:
	storage.clear()

func transferBetweenStorages(storageA: Array[Dictionary], storageB: Array[Dictionary]) -> void:
	storageA.append_array(storageB)


func getShapeCount(shape: Shape.ShapeSprite) -> int:
	var count: int = 0
	
	for dict in gridStorage:
		var storedShape = dict["shape"]
		if storedShape.shapeSprite == shape:
			count += 1
		
	return count

#endregion
