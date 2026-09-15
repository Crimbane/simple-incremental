extends Node


var money: int = 100
var time: float = 0.0
var interval: float = 1 # Seconds between increments
const BASE_INCREMENT_AMOUNT: int = 0
var incrementAmount: int = 0 

var gridStorage: Array[Dictionary]

var UIManager: Node = null

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

#region Grid

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

#endregion
