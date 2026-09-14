extends Control


const SHAPE: PackedScene = preload("uid://5qtpdede8o7j")
const GRID_SLOT_BUTTON: PackedScene = preload("uid://dvinbarfymwhy")

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
