extends Node


var money: int = 0
var time: float = 0.0
var interval: float = 0.1 # Seconds between increments
var incrementAmount: int = 10

var gridStorage: Array[Dictionary]


func _ready() -> void:
	pass # Replace with function body.


func _process(delta: float) -> void:
	time += delta
	
	if time > interval:
		time = 0
		money += incrementAmount
		UIManager.updateMoneyUI()


func addMoney(amount: int) -> void:
	money += amount
	UIManager.updateMoneyUI()


func removeMoney(amount: int) -> void:
	money -= amount
	UIManager.updateMoneyUI()

func addShapeToStorage(slot: int, shape: Node2D) -> void:
	gridStorage.append({"slot": slot,"shape": shape})

func removeShapeFromStorage(shape: Node2D) -> void:
	for dict in gridStorage:
		if dict["shape"] == shape:
			gridStorage.erase(dict)
			return

func removeShapeFromStorageSlot(slot: int) -> void:
	for dict in gridStorage:
		if dict["slot"] == slot:
			gridStorage.erase(dict)
			return

func getShapeInStorageBySlot(slot: int) -> Node2D:
	for dict in gridStorage:
		if dict["slot"] == slot:
			return dict["shape"]
	return null

func getSlotInStorageByShape(shape: Node2D):
	for dict in gridStorage:
		if dict["shape"] == shape:
			return dict["slot"]
	return null
