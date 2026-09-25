extends Control

const GRID_SLOT_BUTTON: PackedScene = preload("uid://dvinbarfymwhy")

@export var rebirthTransition: TextureRect
@export var rebirthScreenshot: TextureRect
@export var moneyLabel: Label
@export var gridContainer: GridContainer
@export var shapeButtons: GridContainer
@export var upgradeBigShapeButton: Button
@export var upgradeMoneyIntervalButton: Button
@export var upgradeGridButton: Button
@export var upgradeSynergyUnlockButton: Button
@export var upgradeSynergyMultiButton: Button

@onready var shaderMaterial = rebirthTransition.material

var ghostStorage: Array[Dictionary]

var shapeHeldByCursor: Shape
var eraserHeldByCursor: Node2D

var shiftHold: bool = false
var leftClickHold: bool = false
var gridLeftClickHold: bool = false


func _ready() -> void:
	GameManager.UIManager = self
	updateGrid()
	
	upgradeBigShapeButton.pressed.connect(GameManager.upgradeBigShape)
	upgradeMoneyIntervalButton.pressed.connect(GameManager.upgradeMoneyInterval)
	upgradeGridButton.pressed.connect(GameManager.upgradeGrid)
	upgradeSynergyUnlockButton.pressed.connect(GameManager.upgradeSynergyUnlock)
	upgradeSynergyMultiButton.pressed.connect(GameManager.upgradeSynergyMultiplier)


func _process(_delta: float) -> void:
	if shapeHeldByCursor:
		shapeHeldByCursor.global_position = get_global_mouse_position()
	elif eraserHeldByCursor:
		eraserHeldByCursor.global_position = get_global_mouse_position()
	
	if Input.is_action_pressed("Shift") and not shiftHold:
		shiftHold = true
	elif not Input.is_action_pressed("Shift") and shiftHold:
		shiftHold = false
		if gridLeftClickHold and ghostStorage:
			banishGhosts()
	if Input.is_action_pressed("Left Click") and not leftClickHold:
		leftClickHold = true
	elif not Input.is_action_pressed("Left Click") and leftClickHold:
		leftClickHold = false
		gridLeftClickHold = false
		if shiftHold and ghostStorage:
			convertGhosts()
	if Input.is_action_just_pressed("Right Click"):
		if shapeHeldByCursor and shapeHeldByCursor.isPurchaseShape:
			shapeHeldByCursor.queue_free()
		if ghostStorage:
			banishGhosts()
	
	
	updateMoneyUI()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("Left Click"):
		if shapeHeldByCursor:
			if GameManager.getSlotInStorageByShape(shapeHeldByCursor) == null:
				print("cancel")
				shapeHeldByCursor.queue_free()


func updateMoneyUI() -> void:
	if not moneyLabel:
		return
	
	moneyLabel.text = "Vertices:\n" + formatMoney(GameManager.money, GameManager.notationStyle)

func updateColor() -> void:
	for button: Button in shapeButtons.get_children():
		var buttonIcon = button.get_node("Icon")
		var buttonShadow = buttonIcon.get_node("DropShadow")
		buttonIcon.modulate = GameManager.StateInfo[GameManager.currentState].ColorRGB
		if GameManager.currentState == GameManager.State.Black:
			buttonShadow.material.set_shader_parameter("blur_color", Color(1.0, 1.0, 1.0, 1.0))
			buttonShadow.material.set_shader_parameter("blur_alpha", 4.0)
			button.self_modulate = Color(0.663, 0.663, 1.0)
	if GameManager.currentState == GameManager.State.Black:
		var topPanel: Panel = %TopPanel
		var leftPanel: Panel = %LeftPanel
		var shapeZonePanel: Panel = %ShapeZonePanel
		var topPanelStyle: StyleBoxFlat = topPanel.get_theme_stylebox("panel")
		var leftPanelStyle: StyleBoxFlat = leftPanel.get_theme_stylebox("panel")
		var shapeZonePanelStyle: StyleBoxFlat = shapeZonePanel.get_theme_stylebox("panel")
		
		topPanelStyle.bg_color = Color(0.307, 0.065, 0.238)
		topPanelStyle.border_color = Color(0.286, 0.506, 0.612)
		leftPanelStyle.bg_color = Color(0.307, 0.065, 0.238)
		leftPanelStyle.border_color = Color(0.286, 0.506, 0.612)
		shapeZonePanelStyle.bg_color = Color(0.0, 0.0, 0.0)
		
		upgradeBigShapeButton.self_modulate = Color(0.663, 0.663, 1.0)
		upgradeMoneyIntervalButton.self_modulate = Color(0.663, 0.663, 1.0)
		
		for slot: Button in gridContainer.get_children():
			slot.self_modulate = Color(0.663, 0.663, 1.0)


func createPreRebirthScreenshot() -> void:
	await RenderingServer.frame_post_draw
	var screenshot = get_viewport().get_texture().get_image()
	rebirthTransition.texture = ImageTexture.create_from_image(screenshot)
	rebirthScreenshot.texture = ImageTexture.create_from_image(screenshot)
	rebirthTransition.visible = true
	rebirthScreenshot.visible = true

func playRebirthTransition(color: Color) -> void:
	shaderMaterial.set_shader_parameter("trans_color", color)
	shaderMaterial.set_shader_parameter("start_position", get_local_mouse_position() / Vector2(get_viewport_rect().size))
	shaderMaterial.set_shader_parameter("invert", 1.0)
	shaderMaterial.set_shader_parameter("progress", 1.0)
	var tween = create_tween()
	tween.tween_method(set_shader_progress, 1.0, 0.0, 2).set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_OUT)
	await tween.finished
	rebirthScreenshot.visible = false
	var tween2 = create_tween()
	tween2.tween_method(set_shader_progress, 0.0, 1.0, 2).set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_IN)
	await tween2.finished
	#tween.stop()
	#shaderMaterial.set_shader_parameter("invert", 0.0)
	#shaderMaterial.set_shader_parameter("progress", 1.0)
	#tween.play()
	#await tween.finished
	rebirthTransition.visible = false
	
func set_shader_progress(value: float) -> void:
	shaderMaterial.set_shader_parameter("progress", value)


#region Grid
func addShapeToCursor(shape: Shape) -> void:
	shapeHeldByCursor = shape

func addEraserToCursor(eraser: Node2D) -> void:
	eraserHeldByCursor = eraser


func _on_grid_button_pressed(gridButton: Button, slot: int, centerPosition: Vector2) -> void:
	gridLeftClickHold = true
	var shapeInThisSlot: Shape = GameManager.getShapeInStorageBySlot(slot)
	if shapeHeldByCursor and not shapeInThisSlot:
		var move = false
		if GameManager.getSlotInStorageByShape(shapeHeldByCursor) == null:
			print("place")
			shapeHeldByCursor.isPurchaseShape = false
			
			if GameManager.money >= shapeHeldByCursor.cost:
				if shiftHold:
					shapeHeldByCursor.isGhostShape = true
					GameManager.addShapeToStorage(slot, shapeHeldByCursor, ghostStorage)
				else:
					GameManager.unlockNextShapeButton(shapeHeldByCursor.shapeSprite + 1)
					GameManager.addShapeToStorage(slot, shapeHeldByCursor)
					GameManager.removeMoney(shapeHeldByCursor.cost)
					
					
				GameManager.calculateMoneyIncrement()
			else:
				print("You are poor")
				shapeHeldByCursor.queue_free()
				return
		else:
			print("move")
			move = true
			GameManager.removeShapeFromStorage(shapeHeldByCursor)
			GameManager.addShapeToStorage(slot, shapeHeldByCursor)
		
		shapeHeldByCursor.reparent(gridButton)
		shapeHeldByCursor.position = centerPosition
		
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
		shapeHeldByCursor.position = centerPosition
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
		
		limboShape.position = centerPosition
		
	elif not shapeHeldByCursor and shapeInThisSlot and not eraserHeldByCursor:
		print("pickup")
		
		shapeInThisSlot.reparent(self)
		shapeHeldByCursor = shapeInThisSlot
		
	elif eraserHeldByCursor and shapeInThisSlot:
		if shiftHold:
			var newGhostEraser: Node2D = eraserHeldByCursor.duplicate()
			gridButton.add_child(newGhostEraser)
			newGhostEraser.isGhostShape = true
			newGhostEraser.position = centerPosition
			GameManager.addShapeToStorage(slot, newGhostEraser, ghostStorage)
		else:
			GameManager.removeShapeFromStorage(shapeInThisSlot)
			shapeInThisSlot.queue_free()
			GameManager.calculateMoneyIncrement()


func _on_grid_slot_hovered(gridButton: Button, slot: int, centerPosition: Vector2) -> void:
	if shiftHold and gridLeftClickHold and shapeHeldByCursor:
		if shapeHeldByCursor.isPurchaseShape:
			var shapeInThisSlot: Shape = GameManager.getShapeInStorageBySlot(slot)
			var ghostInThisSlot: Shape = GameManager.getShapeInStorageBySlot(slot, ghostStorage)
			
			if not shapeInThisSlot and not ghostInThisSlot:
				var newGhostShape: Shape = shapeHeldByCursor.duplicate()
				gridButton.add_child(newGhostShape)
				newGhostShape.isGhostShape = true
				newGhostShape.position = centerPosition
				GameManager.addShapeToStorage(slot, newGhostShape, ghostStorage)
	elif shiftHold and gridLeftClickHold and eraserHeldByCursor:
		var shapeInThisSlot: Shape = GameManager.getShapeInStorageBySlot(slot)
		var ghostInThisSlot: Node2D = GameManager.getShapeInStorageBySlot(slot, ghostStorage)
		
		if shapeInThisSlot and not ghostInThisSlot:
			var newGhostEraser: Node2D = eraserHeldByCursor.duplicate()
			gridButton.add_child(newGhostEraser)
			newGhostEraser.isGhostShape = true
			newGhostEraser.position = centerPosition
			GameManager.addShapeToStorage(slot, newGhostEraser, ghostStorage)

func convertGhosts() -> void:
	if shapeHeldByCursor:
		var cost: int = 0
		
		for dict in ghostStorage:
			cost += dict["shape"].cost
		
		if GameManager.money >= cost:
			GameManager.removeMoney(cost)
			GameManager.unlockNextShapeButton(shapeHeldByCursor.shapeSprite + 1)
			for dict in ghostStorage:
				dict["shape"].isGhostShape = false
			GameManager.transferBetweenStorages(GameManager.gridStorage, ghostStorage)
			GameManager.clearStorage(ghostStorage)
			GameManager.calculateMoneyIncrement()
		else:
			print("You are poor")
			banishGhosts()
			shapeHeldByCursor.queue_free()
	
	elif eraserHeldByCursor:
		for dict in ghostStorage.duplicate():
			GameManager.getShapeInStorageBySlot(dict["slot"]).queue_free()
			GameManager.removeShapeFromStorageSlot(dict["slot"])
			dict["shape"].queue_free()
			GameManager.removeShapeFromStorageSlot(dict["slot"], ghostStorage)
			GameManager.calculateMoneyIncrement()

func banishGhosts() -> void:
	for dict in ghostStorage:
		dict["shape"].queue_free()
	GameManager.clearStorage(ghostStorage)


func clearShapesInGrid() -> void:
	for button in gridContainer.get_children():
		var shape = button.get_children()
		if shape:
			shape[0].queue_free()


func updateGrid() -> void:
	if not gridContainer:
		print("No grid container")
		return
	if GameManager.gridSize < 1:
		push_error("Grid size cannot be smaller than 1")
		return
	
	var buttonsInGrid = gridContainer.get_children()
	var currentAmountOfButtons = buttonsInGrid.size()
	var totalButtonAmountNeeded = GameManager.gridSize * GameManager.gridSize
	
	if currentAmountOfButtons == totalButtonAmountNeeded:
		return
	if totalButtonAmountNeeded < currentAmountOfButtons:
		for button in buttonsInGrid:
			button.queue_free()
		currentAmountOfButtons = 0
	
	var amountOfButtonsToAdd = 0
	if currentAmountOfButtons == 0:
		amountOfButtonsToAdd = totalButtonAmountNeeded
	elif currentAmountOfButtons < totalButtonAmountNeeded:
		amountOfButtonsToAdd = totalButtonAmountNeeded - currentAmountOfButtons
	else:
		return
	
	for i in range(amountOfButtonsToAdd):
		var newButton: Button = GRID_SLOT_BUTTON.instantiate()
		gridContainer.add_child(newButton)
		var centerPosition = newButton.size / 2
		newButton.button_down.connect(_on_grid_button_pressed.bind(newButton, gridContainer.get_children().find(newButton), centerPosition))
		newButton.mouse_entered.connect(_on_grid_slot_hovered.bind(newButton, gridContainer.get_children().find(newButton), centerPosition))
	
	gridContainer.columns = GameManager.gridSize
#endregion

#region Number Formatting

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

func formatMoney(value: int, notationStyle: GameManager.NotationStyle) -> String:
	var NotationStyle = GameManager.NotationStyle
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
	
	return ("%.2f" % snapped(newValue, 0.01)) + suffix

#endregion
