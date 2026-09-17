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
var ghostStorage: Array[Dictionary]

var shapeHeldByCursor: Shape

var shiftHold: bool = false
var leftClickHold: bool = false
var gridLeftClickHold: bool = false

func _ready() -> void:
	GameManager.UIManager = self
	updateGrid()
	
	upgradeColorButton.pressed.connect(GameManager.upgradeColor)


func _process(_delta: float) -> void:
	if shapeHeldByCursor:
		shapeHeldByCursor.global_position = get_global_mouse_position()
	
	if Input.is_action_pressed("Shift") and not shiftHold:
		shiftHold = true
	elif not Input.is_action_pressed("Shift") and shiftHold:
		shiftHold = false
	if Input.is_action_pressed("Left Click") and not leftClickHold:
		leftClickHold = true
	elif not Input.is_action_pressed("Left Click") and leftClickHold:
		leftClickHold = false
		gridLeftClickHold = false
	
	
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
func addShapeToCursor(shape: Shape) -> void:
	#UIManager.reparent(shape)
	shapeHeldByCursor = shape


func _on_grid_button_pressed(gridButton: Button, slot: int) -> void:
	gridLeftClickHold = true
	var shapeInThisSlot: Shape = GameManager.getShapeInStorageBySlot(slot)
	if shapeHeldByCursor and not shapeInThisSlot:
		var move = false
		if GameManager.getSlotInStorageByShape(shapeHeldByCursor) == null:
			print("place")
			shapeHeldByCursor.isPurchaseShape = false
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
			move = true
			GameManager.removeShapeFromStorage(shapeHeldByCursor)
			GameManager.addShapeToStorage(slot, shapeHeldByCursor)
			GameManager.calculateMoneyIncrement()
		
		
		shapeHeldByCursor.reparent(gridButton)
		shapeHeldByCursor.global_position = gridButton.global_position + Vector2(16, 16)
		
		if not move and shiftHold:
			var newShape: Shape = shapeHeldByCursor.duplicate()
			newShape.isPurchaseShape = true
			self.add_child(newShape)
			shapeHeldByCursor = newShape
		else:
			shapeHeldByCursor = null
		
	elif shapeHeldByCursor and shapeInThisSlot == shapeHeldByCursor:
		print("place back")
		
		shapeHeldByCursor.reparent(gridButton)
		shapeHeldByCursor.global_position = gridButton.global_position + Vector2(16, 16)
		shapeHeldByCursor = null
	
	elif shapeHeldByCursor and shapeInThisSlot and not shapeHeldByCursor.isPurchaseShape:
		print("swap")
		
		var limboShape = shapeHeldByCursor
		var limboSlot = GameManager.getSlotInStorageByShape(shapeHeldByCursor)
		
		shapeHeldByCursor = shapeInThisSlot
		shapeHeldByCursor.reparent(self)
		limboShape.reparent(gridButton)
		
		GameManager.removeShapeFromStorage(limboShape)
		GameManager.removeShapeFromStorage(shapeHeldByCursor)
		GameManager.addShapeToStorage(limboSlot, shapeHeldByCursor)
		GameManager.addShapeToStorage(slot, limboShape)
		
		limboShape.global_position = gridButton.global_position + Vector2(16, 16)
		
	elif not shapeHeldByCursor and shapeInThisSlot:
		print("pickup")
		
		shapeInThisSlot.reparent(self)
		shapeHeldByCursor = shapeInThisSlot


func _on_grid_slot_hovered(gridButton: Button, slot: int) -> void:
	if shiftHold and gridLeftClickHold and shapeHeldByCursor:
		var shapeInThisSlot: Shape = GameManager.getShapeInStorageBySlot(slot)
		var ghostInThisSlot: Shape = GameManager.getShapeInStorageBySlot(slot, ghostStorage)
		
		if not shapeInThisSlot and not ghostInThisSlot:
			var newGhostShape: Shape = shapeHeldByCursor.duplicate()
			gridButton.add_child(newGhostShape)
			newGhostShape.isGhostShape = true
			newGhostShape.global_position = gridButton.global_position + Vector2(16, 16)
			GameManager.addShapeToStorage(slot, newGhostShape, ghostStorage)
	if shiftHold and not gridLeftClickHold and shapeHeldByCursor and ghostStorage.size() != 0:
		var cost: int = 0
		for dict in ghostStorage:
			cost += dict["shape"].getShapeValue()
		if GameManager.money >= cost:
				GameManager.removeMoney(cost)
		else:
			print("You are poor")
			shapeHeldByCursor.queue_free()
			return
		GameManager.transferBetweenStorages(GameManager.gridStorage, ghostStorage)
		GameManager.clearStorage(ghostStorage)


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
		var newButton: Button = GRID_SLOT_BUTTON.instantiate()
		gridContainer.add_child(newButton)
		newButton.button_down.connect(_on_grid_button_pressed.bind(newButton, gridContainer.get_children().find(newButton)))
		newButton.mouse_entered.connect(_on_grid_slot_hovered.bind(newButton, gridContainer.get_children().find(newButton)))
	
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
	MILLION = {SCIENTIFIC = "e6", ENGINEERING = "e6", ABBREVIATION = "M"},
	TEN_MILLION = {SCIENTIFIC = "e7"},
	HUNDRED_MILLION = {SCIENTIFIC = "e8"},
	BILLION = {SCIENTIFIC = "e9", ENGINEERING = "e9", ABBREVIATION = "B"},
	TEN_BILLION = {SCIENTIFIC = "e10"},
	HUNDRED_BILLION = {SCIENTIFIC = "e11"},
	TRILLION = {SCIENTIFIC = "e12", ENGINEERING = "e12", ABBREVIATION = "T"},
	TEN_TRILLION = {SCIENTIFIC = "e13"},
	HUNDRED_TRILLION = {SCIENTIFIC = "e14"},
	QUADRILLION = {SCIENTIFIC = "e15", ENGINEERING = "e15", ABBREVIATION = "Qd"},
	TEN_QUADRILLION = {SCIENTIFIC = "e16"},
	HUNDRED_QUADRILLION = {SCIENTIFIC = "e17"},
	QUINTILLION = {SCIENTIFIC = "e18", ENGINEERING = "e18", ABBREVIATION = "Qn"}
}

func formatMoney(value: int, notationStyle: NotationStyle) -> String:
	if notationStyle == NotationStyle.NONE or value < BigNumbers.MILLION:
		return str(value)
	
	var searchKey: String
	
	for numKey in BigNumbers:
		if notationStyle != NotationStyle.SCIENTIFIC and ("TEN" in numKey or "HUNDRED" in numKey):
			continue
		if value >= BigNumbers[numKey]:
			searchKey = numKey
		else:
			break
	
	var suffix = notations[searchKey][NotationStyle.find_key(notationStyle)] if searchKey else ""
	var newValue = float(value) / BigNumbers[searchKey] if searchKey else value
	
	return str(snapped(newValue, 0.001)) + suffix

#endregion
