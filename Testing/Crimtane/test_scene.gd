extends Control


const SHAPE: PackedScene = preload("uid://5qtpdede8o7j")
const GRID_SLOT_BUTTON: PackedScene = preload("uid://dvinbarfymwhy")

enum NotationStyle {
	NONE,
	ABBREVIATION,
	SCIENTIFIC,
	ENGINEERING
}

enum BigNumbers {
	MILLION = 10**6,
	TEN_MILLION = 10**7,
	HUNDRED_MILLION = 10**8,
	BILLION = 10**9,
	TEN_BILLION = 10**10,
	HUNDRED_BILLION = 10**11,
	TRILLION = 10**12,
	TEN_TRILLION = 10**13,
	HUNDRED_TRILLION = 10**14,
	QUADRILLION = 10**15,
	TEN_QUADRILLION = 10**16,
	HUNDRED_QUADRILLION = 10**17,
	QUINTILLION = 10**18
}

var notations: Dictionary = {
	MILLION = {ABBREVIATION = "M", SCIENTIFIC = "e6", ENGINEERING = "e6"},
	TEN_MILLION = {SCIENTIFIC = "e7"},
	HUNDRED_MILLION = {SCIENTIFIC = "e8"},
	BILLION = {ABBREVIATION = "B", SCIENTIFIC = "e9", ENGINEERING = "e9"},
	TEN_BILLION = {SCIENTIFIC = "e10"},
	HUNDRED_BILLION = {SCIENTIFIC = "e11"},
	TRILLION = {ABBREVIATION = "T", SCIENTIFIC = "e12", ENGINEERING = "e12"},
	TEN_TRILLION = {SCIENTIFIC = "e13"},
	HUNDRED_TRILLION = {SCIENTIFIC = "e14"},
	QUADRILLION = {ABBREVIATION = "Qd", SCIENTIFIC = "e15", ENGINEERING = "e15"},
	TEN_QUADRILLION = {SCIENTIFIC = "e16"},
	HUNDRED_QUADRILLION = {SCIENTIFIC = "e17"},
	QUINTILLION = {ABBREVIATION = "Qn", SCIENTIFIC = "e18", ENGINEERING = "e18"}
}

@export var gridSize: int = 3:
	set(value):
		gridSize = value
		updateGrid()

@onready var shapeButton: Button = $Button
@onready var gridContainer: GridContainer = $GridContainer

var shapeHeldByCursor: Node2D
var gridButtons: Array
var gridStorage: Array[Dictionary]


func _ready() -> void:
	print(formatMoney(12345678, NotationStyle.SCIENTIFIC))
	shapeButton.button_down.connect(_on_shape_button_press)
	updateGrid()


func _process(_delta: float) -> void:
	if shapeHeldByCursor:
		shapeHeldByCursor.global_position = get_global_mouse_position()	

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("Left Click"):
		if shapeHeldByCursor:
			if getSlotInStorageByShape(shapeHeldByCursor) == null:
				print("cancel")
				shapeHeldByCursor.queue_free()
			else:
				print("delete")
				removeShapeFromStorage(shapeHeldByCursor)
				shapeHeldByCursor.queue_free()
				

func _on_shape_button_press() -> void:
	if shapeHeldByCursor:
		return
		
	var newShape = SHAPE.instantiate()
	shapeHeldByCursor = newShape
	add_child(newShape)


func _on_grid_button_pressed(gridButton: Button, slot: int) -> void:
	
	if shapeHeldByCursor and not getShapeInStorageBySlot(slot):
		if getSlotInStorageByShape(shapeHeldByCursor) == null:
			print("place")
			addShapeToStorage(slot, shapeHeldByCursor)
		else:
			print("move")
			removeShapeFromStorage(shapeHeldByCursor)
			addShapeToStorage(slot, shapeHeldByCursor)
		
		shapeHeldByCursor.reparent(gridButton)
		shapeHeldByCursor.global_position = gridButton.global_position + Vector2(16, 16)
		shapeHeldByCursor = null
		
	elif shapeHeldByCursor and getShapeInStorageBySlot(slot) == shapeHeldByCursor:
		print("place back")
		
		shapeHeldByCursor.reparent(gridButton)
		shapeHeldByCursor.global_position = gridButton.global_position + Vector2(16, 16)
		shapeHeldByCursor = null
		
	elif not shapeHeldByCursor and getShapeInStorageBySlot(slot):
		print("pickup")
		
		getShapeInStorageBySlot(slot).reparent(self)
		shapeHeldByCursor = getShapeInStorageBySlot(slot)


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


func updateGrid() -> void:
	if not gridContainer:
		return
	if gridSize < 1:
		push_error("Grid size cannot be smaller than 0")
		return
	
	var buttonsInGrid = gridContainer.get_children()
	var currentAmountOfButtons = buttonsInGrid.size()
	var totalButtonAmountNeeded = gridSize * gridSize
	
	if currentAmountOfButtons == totalButtonAmountNeeded:
		return
	
	var amountOfButtonsToAdd = 0
	if currentAmountOfButtons == 0:
		amountOfButtonsToAdd = totalButtonAmountNeeded
	elif currentAmountOfButtons < totalButtonAmountNeeded:
		amountOfButtonsToAdd = totalButtonAmountNeeded - currentAmountOfButtons
	else:
		#Code for downgrading grid?
		return
	
	for i in range(amountOfButtonsToAdd):
		var newButton = GRID_SLOT_BUTTON.instantiate()
		gridContainer.add_child(newButton)
		newButton.button_down.connect(_on_grid_button_pressed.bind(newButton, gridContainer.get_children().find(newButton)))
	
	gridContainer.columns = gridSize
	gridButtons = gridContainer.get_children()








func formatMoney(value: int, notationStyle: NotationStyle) -> String:
	if notationStyle == NotationStyle.NONE or value < BigNumbers.MILLION:
		return str(value)
	
	var suffix: String = ""
	var newValue: float = float(value)
	var searchKey: String
	
	for numKey in BigNumbers:
		if notationStyle != NotationStyle.SCIENTIFIC and ("TEN" in numKey or "HUNDRED" in numKey):
			continue
		if value >= BigNumbers[numKey]:
			searchKey = numKey
		else:
			break
	
	suffix = notations[searchKey][NotationStyle.find_key(notationStyle)]
	newValue = float(value) / BigNumbers[searchKey]
	
	return str(snapped(newValue, 0.001)) + suffix
