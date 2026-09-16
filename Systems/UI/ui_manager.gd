extends Control

const GRID_SLOT_BUTTON: PackedScene = preload("uid://dvinbarfymwhy")

@export var gridSize: int = 3:
	set(value):
		gridSize = value
		updateGrid()

@export var moneyLabel: Label
@export var gridContainer: GridContainer
@export var upgradeColorButton: Button

var gridButtons: Array

var shapeHeldByCursor: Node2D

func _ready() -> void:
	GameManager.UIManager = self
	updateGrid()
	
	upgradeColorButton.pressed.connect(GameManager.upgradeColor)


func _process(_delta: float) -> void:
	if shapeHeldByCursor:
		shapeHeldByCursor.global_position = get_global_mouse_position()
	
	updateMoneyUI()


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
				GameManager.calculateMoneyIncrement()


func updateMoneyUI() -> void:
	if not moneyLabel:
		return
	
	moneyLabel.text = "Vertices: " + str(formatMoney(GameManager.money, NotationStyle.ABBREVIATION))

func updateColor() -> void:
	var shapeColor: String = GameManager.shapeColor
	for button in $ShapeButtons.get_children():
		var textureRect = button.get_node("TextureRect")
		match shapeColor:
			"White":
				textureRect.modulate = Color.WHITE
			"Red":
				textureRect.modulate = Color.RED
			"Orange":
				textureRect.modulate = Color.ORANGE
			"Yellow":
				textureRect.modulate = Color.YELLOW
			"Green":
				textureRect.modulate = Color.GREEN
			"Blue":
				textureRect.modulate = Color.BLUE
			"Purple":
				textureRect.modulate = Color.PURPLE
			"Black":
				textureRect.modulate = Color.BLACK


#region Grid
func addShapeToCursor(shape: Node2D) -> void:
	#UIManager.reparent(shape)
	shapeHeldByCursor = shape


func _on_grid_button_pressed(gridButton: Button, slot: int) -> void:
	
	if shapeHeldByCursor and not GameManager.getShapeInStorageBySlot(slot):
		if GameManager.getSlotInStorageByShape(shapeHeldByCursor) == null:
			print("place")
			
			if GameManager.money >= shapeHeldByCursor.cost:
				GameManager.removeMoney(shapeHeldByCursor.cost)
			else:
				print("You are poor")
				shapeHeldByCursor.queue_free()
				return
			GameManager.addShapeToStorage(slot, shapeHeldByCursor)
			GameManager.calculateMoneyIncrement()
		else:
			print("move")
			GameManager.removeShapeFromStorage(shapeHeldByCursor)
			GameManager.addShapeToStorage(slot, shapeHeldByCursor)
			GameManager.calculateMoneyIncrement()
		
		shapeHeldByCursor.reparent(gridButton)
		shapeHeldByCursor.global_position = gridButton.global_position + Vector2(16, 16)
		shapeHeldByCursor = null
		
	elif shapeHeldByCursor and GameManager.getShapeInStorageBySlot(slot) == shapeHeldByCursor:
		print("place back")
		
		shapeHeldByCursor.reparent(gridButton)
		shapeHeldByCursor.global_position = gridButton.global_position + Vector2(16, 16)
		shapeHeldByCursor = null
		
	elif not shapeHeldByCursor and GameManager.getShapeInStorageBySlot(slot):
		print("pickup")
		
		GameManager.getShapeInStorageBySlot(slot).reparent(self)
		shapeHeldByCursor = GameManager.getShapeInStorageBySlot(slot)


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
#endregion

#region Number Formatting
enum NotationStyle {
	NONE,
	ABBREVIATION,
	SCIENTIFIC,
	ENGINEERING
}

enum BigNumbers {
	MILLION = 10**6,
	BILLION = 10**9,
	TRILLION = 10**12,
	QUADRILLION = 10**15,
	QUINTILLION = 10**18
}

enum BigNumbersScientific {
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
	TEN_MILLION = {ABBREVIATION = "M", SCIENTIFIC = "e7", ENGINEERING = "e6"},
	HUNDRED_MILLION = {ABBREVIATION = "M", SCIENTIFIC = "e8", ENGINEERING = "e6"},
	BILLION = {ABBREVIATION = "B", SCIENTIFIC = "e9", ENGINEERING = "e9"},
	TEN_BILLION = {ABBREVIATION = "B", SCIENTIFIC = "e10", ENGINEERING = "e9"},
	HUNDRED_BILLION = {ABBREVIATION = "B", SCIENTIFIC = "e11", ENGINEERING = "e9"},
	TRILLION = {ABBREVIATION = "T", SCIENTIFIC = "e12", ENGINEERING = "e12"},
	TEN_TRILLION = {ABBREVIATION = "T", SCIENTIFIC = "e13", ENGINEERING = "e12"},
	HUNDRED_TRILLION = {ABBREVIATION = "T", SCIENTIFIC = "e14", ENGINEERING = "e12"},
	QUADRILLION = {ABBREVIATION = "Qd", SCIENTIFIC = "e15", ENGINEERING = "e15"},
	TEN_QUADRILLION = {ABBREVIATION = "Qd", SCIENTIFIC = "e16", ENGINEERING = "e15"},
	HUNDRED_QUADRILLION = {ABBREVIATION = "Qd", SCIENTIFIC = "e17", ENGINEERING = "e15"},
	QUINTILLION = {ABBREVIATION = "Qn", SCIENTIFIC = "e18", ENGINEERING = "e18"}
}

func formatMoney(value: int, notationStyle: NotationStyle) -> String:
	if notationStyle == NotationStyle.NONE or value < BigNumbers.MILLION:
		return str(value)
	
	var suffix: String = ""
	var newValue: float = float(value)
	
	var testNum
	
	if notationStyle == NotationStyle.SCIENTIFIC:
		for bigNum in BigNumbersScientific:
			if value >= BigNumbersScientific[bigNum]:
				testNum = bigNum
			else:
				break
	else:
		for bigNum in BigNumbers:
			if value >= BigNumbers[bigNum]:
				testNum = bigNum
			else:
				break
	
	suffix = notations[testNum][NotationStyle.find_key(notationStyle)]
	newValue = float(value) / BigNumbersScientific[testNum]
	
	
	return str(snapped(newValue, 0.001)) + suffix

#endregion
