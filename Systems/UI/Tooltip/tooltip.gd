extends PanelContainer

@export var costLabel: Label
@export var textLabel: Label
@export var functionLabel: Label

@export_multiline var description: String

@onready var parent = $".."

@export_enum("Big Shape", "Rebirth", "Shape", "Interval", "Grid", 
"SynergyUnlock", "SynergyMulti", "MoneyLabel") var parentType: String


func _ready() -> void:
	hide()
	setCost(100)
	setDescription(description)
	
	parent.mouse_entered.connect(onMouseEntered)
	parent.mouse_exited.connect(onMouseExited)


func _process(_delta: float) -> void:
	if visible:
		var mousePosition = get_global_mouse_position() + Vector2(6,0)
		if mousePosition > get_viewport_rect().size - size:
			global_position = mousePosition
			offset_transform_position = -size/2 + Vector2(32, 8)
		else:
			global_position = mousePosition
		
		match parentType:
			"Big Shape":
				setBigShapeTooltip()
			"Rebirth":
				setRebirthTooltip()
				global_position = parent.global_position + Vector2(-150,-0)
			"Shape":
				setShapeTooltip()
			"Interval":
				setIntervalTooltip()
			"Grid":
				setGridTooltip()
			"SynergyUnlock":
				setSynergyUnlockTooltip()
			"SynergyMulti":
				setSynergyMultiTooltip()
			"MoneyLabel":
				setMoneyLabelTooltip()
				global_position = parent.global_position + Vector2(-40,56)


func setDescription(text: String) -> void:
	textLabel.text = text

func setCost(cost: int) -> void:
	if GameManager.UIManager == null:
		return
	else:
		var formattedCost = GameManager.UIManager.formatMoney(cost, GameManager.notationStyle)
		costLabel.text = "Cost: " + formattedCost

func onMouseEntered() -> void:
	show()
	

func onMouseExited() -> void:
	hide()

func resizeContainer() -> void:
	hide()
	show()

func setBigShapeTooltip() -> void:
	var currentLevel = GameManager.currentBigShapeType
	if GameManager.currentBigShapeType == GameManager.ShapeType.Circle:
		textLabel.text = "THE PERFECT SHAPE"
		costLabel.hide()
		functionLabel.hide()
		resizeContainer()
		return
	
	var bigShapeMulti = GameManager.ShapeInfo[GameManager.currentBigShapeType].BigShapeMultiplier
	
	
	if currentLevel == GameManager.StateInfo[GameManager.currentState].MaxBigShapeLevel:
		costLabel.hide()
		functionLabel.text = "Current multiplier: " + str(bigShapeMulti) + "x"
		
	else:
		costLabel.show()
		setCost(GameManager.ShapeInfo[GameManager.currentBigShapeType].NextBigShapeCost)
		
		#var nextBigShapeMulti = GameManager.ShapeInfo[GameManager.currentBigShapeType + 1].BigShapeMultiplier
		functionLabel.text = "Current multiplier: " + str(bigShapeMulti) + "x \nNext: " \
		+ str(bigShapeMulti + 1) + "x"
		
	resizeContainer()

func setRebirthTooltip() -> void:
	setCost(GameManager.StateInfo[GameManager.currentState].NextRebirthCost)
	functionLabel.hide()
	resizeContainer()

func setShapeTooltip() -> void:
	var currentCost = GameManager.getShapeCost(parent.cost, parent.shapeSprite)
	GameManager.getShapeSynergyMulti(parent.shapeSprite)
	setCost(currentCost)
	
	var baseGeneration = GameManager.ShapeInfo[parent.shapeSprite].ShapeMultiplier
	var shapeSynergy = GameManager.getShapeSynergyMulti(parent.shapeSprite)
	var colorMultiplier = GameManager.StateInfo[GameManager.currentState].ColorMultiplier
	var generationValue = roundi(baseGeneration * shapeSynergy * colorMultiplier)
	functionLabel.text = "Generates " + str(generationValue) + " vertices"
	if generationValue == 1:
		functionLabel.text = "Generates " + str(generationValue) + " vertex"


func setIntervalTooltip() -> void:
	var currentLevel = GameManager.UpgradeInfo[GameManager.UpgradeType.Interval].CurrentLevel
	var maxLevel = GameManager.UpgradeInfo[GameManager.UpgradeType.Interval].MaxLevel
	var cost = GameManager.UpgradeInfo[GameManager.UpgradeType.Interval].NextLevelCost
	var interval = GameManager.interval
	if currentLevel == maxLevel:
		costLabel.hide()
		functionLabel.text = "Current: " + str(interval) + "s"
		resizeContainer()
		return
	else:
		setCost(cost)
		functionLabel.text = "Current: " + str(interval) + "s Next: " + str(interval - 0.09) + "s"
	

func setGridTooltip() -> void:
	var currentLevel = GameManager.UpgradeInfo[GameManager.UpgradeType.Grid].CurrentLevel
	var maxLevel = GameManager.UpgradeInfo[GameManager.UpgradeType.Grid].MaxLevel
	var cost = GameManager.UpgradeInfo[GameManager.UpgradeType.Grid].NextLevelCost
	
	if currentLevel == maxLevel:
		costLabel.hide()
		functionLabel.text = "Current: " + str(GameManager.gridSize) + "x" + str(GameManager.gridSize)
	else:
		costLabel.show()
		setCost(cost)
		functionLabel.text = "Current: " + str(GameManager.gridSize) + "x" + str(GameManager.gridSize) + \
		" Next: " + str(GameManager.gridSize + 1) + "x" + str(GameManager.gridSize + 1)
	resizeContainer()


func setSynergyUnlockTooltip() -> void:
	var currentLevel = GameManager.UpgradeInfo[GameManager.UpgradeType.SynergyUnlock].CurrentLevel
	var maxLevel = GameManager.UpgradeInfo[GameManager.UpgradeType.SynergyUnlock].MaxLevel
	var cost = GameManager.UpgradeInfo[GameManager.UpgradeType.SynergyUnlock].NextLevelCost
	if currentLevel == maxLevel:
		costLabel.hide()
		functionLabel.show()
		textLabel.text = "Weaker shapes empower stronger shapes"
		
		var synergyMulti = GameManager.synergyMulti * 100
		functionLabel.text = "Dot empowers Pentagon by: " + str(synergyMulti) + "%" + \
		"\nLine empowers Hexagon by: " + str(synergyMulti) + "%" + \
		"\nTriangle empowers Heptagon by: " + str(synergyMulti) + "%" + \
		"\nSquare empowers Octagon by: " + str(synergyMulti) + "%"
		return
	else:
		costLabel.show()
		functionLabel.hide()
		setCost(cost)
	
	resizeContainer()

func setSynergyMultiTooltip() -> void:
	var currentLevel = GameManager.UpgradeInfo[GameManager.UpgradeType.SynergyMulti].CurrentLevel
	var maxLevel = GameManager.UpgradeInfo[GameManager.UpgradeType.SynergyMulti].MaxLevel
	var cost = GameManager.UpgradeInfo[GameManager.UpgradeType.SynergyMulti].NextLevelCost
	var synergyMulti = GameManager.synergyMulti * 100
	if currentLevel == maxLevel:
		costLabel.hide()
		functionLabel.text = "Current strength: " + str(synergyMulti) + "%"
		return
	else:
		costLabel.show()
		setCost(cost)
		functionLabel.text = "Current strength: " + str(synergyMulti) + "% \nNext: " + str(synergyMulti + 10) + "%"
	
	resizeContainer()

func setMoneyLabelTooltip() -> void:
	costLabel.hide()
	textLabel.hide()
	var verticesPerSecond = roundi(GameManager.incrementAmount / GameManager.interval)
	var formattedVPS = GameManager.UIManager.formatMoney(verticesPerSecond, GameManager.notationStyle)
	functionLabel.text = "Vertices per second: " + str(formattedVPS)
