extends PanelContainer

@export var costLabel: Label
@export var textLabel: Label
@export var functionLabel: Label

@export_multiline var description: String

@onready var parent = $".."

@export_enum("Big Shape", "Rebirth", "Shape", "Interval", "Grid") var parentType: String


func _ready() -> void:
	hide()
	setCost(100)
	setDescription(description)
	
	parent.mouse_entered.connect(onMouseEntered)
	parent.mouse_exited.connect(onMouseExited)


func _process(_delta: float) -> void:
	if visible:
		global_position = get_global_mouse_position() + Vector2(6,0)
		
		match parentType:
			"Big Shape":
				setBigShapeCost()
			"Rebirth":
				setRebirthCost()
				global_position = parent.global_position + Vector2(-150,-20)
			"Shape":
				setShapeCost()
			"Interval":
				setIntervalCost()
			"Grid":
				setGridCost()


func setDescription(text: String) -> void:
	textLabel.text = text

func setCost(cost: int) -> void:
	if GameManager.UIManager == null:
		return
	else:
		var formattedCost = GameManager.UIManager.formatMoney(cost, GameManager.notationStyle)
		costLabel.text = "cost: " + formattedCost

func onMouseEntered() -> void:
	show()
	

func onMouseExited() -> void:
	hide()


func setBigShapeCost() -> void:
	if GameManager.currentBigShapeType == GameManager.ShapeType.Circle:
		return
	
	setCost(GameManager.ShapeInfo[GameManager.currentBigShapeType].NextBigShapeCost)

func setRebirthCost() -> void:
	setCost(GameManager.StateInfo[GameManager.currentState].NextRebirthCost)

func setShapeCost() -> void:
	var currentCost = GameManager.getShapeCost(parent.cost, parent.shapeSprite + 1)
	setCost(currentCost)


func setIntervalCost() -> void:
	var currentLevel = GameManager.UpgradeInfo[GameManager.UpgradeType.Interval].CurrentLevel
	var maxLevel = GameManager.UpgradeInfo[GameManager.UpgradeType.Interval].MaxLevel
	var cost = GameManager.UpgradeInfo[GameManager.UpgradeType.Interval].NextLevelCost
	if currentLevel == maxLevel:
		costLabel.hide()
		#costLabel.modulate.a = 0.0
		return
	
	setCost(cost)
	
	var interval = GameManager.interval
	if interval == 0.01:
		functionLabel.text = "Current: " + str(interval) + "s"
	else:
		functionLabel.text = "Current: " + str(interval) + "s Next: " + str(interval - 0.09) + "s"

func setGridCost() -> void:
	var currentLevel = GameManager.UpgradeInfo[GameManager.UpgradeType.Grid].CurrentLevel
	var maxLevel = GameManager.UpgradeInfo[GameManager.UpgradeType.Grid].MaxLevel
	var cost = GameManager.UpgradeInfo[GameManager.UpgradeType.Grid].NextLevelCost
	if currentLevel == maxLevel:
		costLabel.hide()
		return
	else:
		costLabel.show()
	
	setCost(cost)
