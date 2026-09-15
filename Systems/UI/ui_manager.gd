extends Control

const GRID_SLOT_BUTTON: PackedScene = preload("uid://dvinbarfymwhy")

@export var gridSize: int = 3:
	set(value):
		gridSize = value
		updateGrid()

@export var moneyLabel: Label
@export var gridContainer: GridContainer

var gridButtons: Array

var shapeHeldByCursor: Node2D

func _ready() -> void:
	updateGrid()



func _process(_delta: float) -> void:
	if shapeHeldByCursor:
		shapeHeldByCursor.global_position = get_global_mouse_position()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("Left Click"):
		if shapeHeldByCursor:
			if GameManager.getSlotInStorageByShape(shapeHeldByCursor) == null:
				print("cancel")
				shapeHeldByCursor.queue_free()
			else:
				print("delete")
				GameManager.removeShapeFromStorage(shapeHeldByCursor)
				shapeHeldByCursor.queue_free()


func updateMoneyUI() -> void:
	if not moneyLabel:
		return
	
	moneyLabel.text = "Vertices: " + str(GameManager.money)


func addShapeToCursor(shape: Node2D) -> void:
	self.reparent(shape)
	shapeHeldByCursor = shape

func _on_grid_button_pressed(gridButton: Button, slot: int) -> void:
	if UIManager.shapeHeldByCursor and not GameManager.getShapeInStorageBySlot(slot):
		if GameManager.getSlotInStorageByShape(UIManager.shapeHeldByCursor) == null:
			print("place")
			if GameManager.money >= UIManager.shapeHeldByCursor.cost:
				GameManager.removeMoney(UIManager.shapeHeldByCursor.cost)
			else:
				print("You are poor")
				UIManager.shapeHeldByCursor.queue_free()
				return
			GameManager.addShapeToStorage(slot, UIManager.shapeHeldByCursor)
		else:
			print("move")
			GameManager.removeShapeFromStorage(UIManager.shapeHeldByCursor)
			GameManager.addShapeToStorage(slot, UIManager.shapeHeldByCursor)
		
		UIManager.shapeHeldByCursor.reparent(gridButton)
		UIManager.shapeHeldByCursor.global_position = gridButton.global_position + Vector2(16, 16)
		UIManager.shapeHeldByCursor = null
		
	elif UIManager.shapeHeldByCursor and GameManager.getShapeInStorageBySlot(slot) == UIManager.shapeHeldByCursor:
		print("place back")
		
		UIManager.shapeHeldByCursor.reparent(gridButton)
		UIManager.shapeHeldByCursor.global_position = gridButton.global_position + Vector2(16, 16)
		UIManager.shapeHeldByCursor = null
		
	elif not UIManager.shapeHeldByCursor and GameManager.getShapeInStorageBySlot(slot):
		print("pickup")
		
		GameManager.getShapeInStorageBySlot(slot).reparent(self)
		UIManager.shapeHeldByCursor = GameManager.getShapeInStorageBySlot(slot)

func updateGrid() -> void:
	if not gridContainer:
		print("No grid container")
		return
	if gridSize < 1:
		push_error("Grid size cannot be smaller than 1")
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
