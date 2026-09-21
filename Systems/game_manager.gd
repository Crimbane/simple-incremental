extends Node


const BASE_GRID_SIZE: int = 2
const BASE_INCREMENT_AMOUNT: int = 0
const BASE_INTERVAL: float = 1.1

enum NotationStyle { NONE, ABBREVIATION, SCIENTIFIC, ENGINEERING }
var notationStyle: NotationStyle = NotationStyle.ABBREVIATION

var money: int = 1000000
var time: float = 0.0
var interval: float = BASE_INTERVAL # Seconds between increments
var incrementAmount: int = BASE_INCREMENT_AMOUNT
var gridSize: int = 8:
	set(value):
		gridSize = value
		if UIManager:
			UIManager.updateGrid()


enum State { White, Red, Orange, Yellow, Green, Blue, Purple, Black }
var StateInfo: Dictionary[State, StateData] = {
	State.White: StateData.new({
		ColorRGB = Color(0.9, 0.9, 0.9),
		ColorMultiplier = 1,
		NextRebirthCost = 100
	}),
	State.Red: StateData.new({
		ColorRGB = Color(0.8, 0.2, 0.2),
		ColorMultiplier = 2,
		NextRebirthCost = 200
	}),
	State.Orange: StateData.new({
		ColorRGB = Color(1.0, 0.5, 0.0),
		ColorMultiplier = 4,
		NextRebirthCost = 300
	}),
	State.Yellow: StateData.new({
		ColorRGB = Color(1.0, 0.9, 0.0),
		ColorMultiplier = 8,
		NextRebirthCost = 400
	}),
	State.Green: StateData.new({
		ColorRGB = Color(0.2, 0.7, 0.2),
		ColorMultiplier = 16,
		NextRebirthCost = 500
	}),
	State.Blue: StateData.new({
		ColorRGB = Color(0.4, 0.5, 0.8),
		ColorMultiplier = 32,
		NextRebirthCost = 600
	}),
	State.Purple: StateData.new({
		ColorRGB = Color(0.8, 0.2, 0.9),
		ColorMultiplier = 64,
		NextRebirthCost = 700
	}),
	State.Black: StateData.new({
		ColorRGB = Color(0.1, 0.1, 0.1),
		ColorMultiplier = 128
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
		incrementAmount += dict["shape"].getShapeValue()
	
	incrementAmount *= ShapeInfo[currentBigShapeType].BigShapeMultiplier
	print("incrementAmount: ", incrementAmount)


func getShapeCost(baseCost: int, shape: Shape.ShapeSprite) -> int:
	var count: int = getShapeCount(shape)
	
	return roundi(baseCost * pow(1.15, count))

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
	
	bigShape.updateColor()
	UIManager.updateColor()
	UIManager.clearShapesInGrid()
	clearStorage()
	clearUpgrades()
	calculateMoneyIncrement()


func upgradeBigShape() -> void:
	if currentBigShapeType == ShapeType.Circle:
		print("bigshape max level reached")
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
	if interval <= 0.1:
		return
	print("interval")
	interval -= 0.1

func clearUpgrades() -> void:
	gridSize = BASE_GRID_SIZE
	interval = BASE_INTERVAL
	currentBigShapeType = ShapeType.Dot
	bigShape.updateSprite()

#endregion

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
