extends Node


const BASE_GRID_SIZE: int = 2
const BASE_INCREMENT_AMOUNT: int = 0

enum NotationStyle { NONE, ABBREVIATION, SCIENTIFIC, ENGINEERING }
var notationStyle: NotationStyle = NotationStyle.ABBREVIATION

var money: int = 1000000
var time: float = 0.0
var interval: float = 1 # Seconds between increments
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
		ColorMultiplier = 128,
		NextRebirthCost = 0
	})
}
var currentState: int = State.White


var bigShapeSprite: String = "Dot"
var bigShapeNames: Array[String] = [
	"Dot",
	"Line",
	"Triangle",
	"Square",
	"Pentagon",
	"Hexagon",
	"Heptagon",
	"Octagon",
	"Nonagon",
	"Decagon"
]
var currentBigShapeIndex = 0
var bigShapeDict: Dictionary = {
	"Dot": {
		"multiplier": 1,
		"cost": 100
	},
	"Line": {
		"multiplier": 2,
		"cost": 200
	},
	"Triangle": {
		"multiplier": 3,
		"cost": 300
	},
	"Square": {
		"multiplier": 4,
		"cost": 400
	},
	"Pentagon": {
		"multiplier": 5,
		"cost": 500
	},
	"Hexagon": {
		"multiplier": 6,
		"cost": 600
	},
	"Heptagon": {
		"multiplier": 7,
		"cost": 700
	},
	"Octagon": {
		"multiplier": 8,
		"cost": 800
	},
	"Nonagon": {
		"multiplier": 9,
		"cost": 900
	},
	"Decagon": {
		"multiplier": 10,
		"cost": 1000
	}
}

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
	
	var bigShapeMultiplier = bigShapeDict[bigShapeSprite]["multiplier"]
	
	incrementAmount *= bigShapeMultiplier
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
	gridSize = BASE_GRID_SIZE
	
	bigShape.updateColor()
	UIManager.updateColor()
	UIManager.clearShapesInGrid()
	clearStorage()
	#clearUpgrades()
	calculateMoneyIncrement()


func upgradeBigShape() -> void:
	if currentBigShapeIndex >= bigShapeNames.size() - 1:
		print("bigshape max level reached")
		return
	var nextShape: String = bigShapeNames[currentBigShapeIndex + 1]
	var cost: int = bigShapeDict[nextShape]["cost"]
	
	if money < cost:
		print("Not enough money")
		return
	
	removeMoney(cost)
	
	currentBigShapeIndex += 1
	bigShapeSprite = bigShapeNames[currentBigShapeIndex]
	print("BigshapeSprite: ", bigShapeSprite)
	bigShape.updateSprite()
	
	print("upgraded big shape to ", currentBigShapeIndex)
	calculateMoneyIncrement()

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
