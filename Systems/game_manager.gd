extends Node


var money: int = 1000000
var time: float = 0.0
var interval: float = 1 # Seconds between increments
const BASE_INCREMENT_AMOUNT: int = 0
var incrementAmount: int = 0 

var shapeColor: String = "White"
var currentColorsIndex: int = 0
var colors: Array[String] = [
	"White",
	"Red",
	"Orange",
	"Yellow",
	"Green",
	"Blue",
	"Purple",
	"Black"
]
var upgradeColorsIndex: int = 0
var upgradeColorCost: Array[int] = [
	100, #Red
	200, #Orange
	300, #Yellow
	400, #Greem
	500, #Blue
	600, #Purple
	800, #Black
	-1
]

var gridStorage: Array[Dictionary]

var UIManager: Node = null
var upgraded = false

func _ready() -> void:
	pass # Replace with function body.


func _process(delta: float) -> void:
	time += delta
	
	if time > interval:
		time = 0
		money += incrementAmount


func addMoney(amount: int) -> void:
	money += amount


func removeMoney(amount: int) -> void:
	money -= amount


func calculateMoneyIncrement() -> void:
	incrementAmount = BASE_INCREMENT_AMOUNT
	for dict in gridStorage:
		incrementAmount += dict["shape"].getShapeValue()
	print("incrementAmount: ", incrementAmount)


func upgradeColor() -> void:
	upgradeColorsIndex = currentColorsIndex
	
	if money < upgradeColorCost[upgradeColorsIndex] :
		print("Not enough money")
		return
	
	if currentColorsIndex == colors.size() - 1:
		return
	
	removeMoney(upgradeColorCost[upgradeColorsIndex])
	
	currentColorsIndex += 1
	shapeColor = colors[currentColorsIndex]
	
	UIManager.updateColor()
	
	for dict in gridStorage:
		dict["shape"].updateColor()
	calculateMoneyIncrement()

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

#endregion
