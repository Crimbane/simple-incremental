extends Node2D

@onready var topPanelObject: Node2D = $TopPanel
@onready var leftPanelObject: Node2D = $LeftPanel
@onready var moneyLabelObject: Node2D = $MoneyLabel
@onready var trashcanObject: Node2D = $Trashcan
@onready var eraserObject: Node2D = $Eraser
@onready var upgrade1Object: Node2D = $Upgrade1
@onready var upgrade2Object: Node2D = $Upgrade2
@onready var upgrade3Object: Node2D = $Upgrade3
@onready var upgrade4Object: Node2D = $Upgrade4
@onready var upgrade5Object: Node2D = $Upgrade5

@onready var topPanel: Control = topPanelObject.get_child(0)
@onready var leftPanel: Control = leftPanelObject.get_child(0)
@onready var moneyLabel: Control = moneyLabelObject.get_child(0)
@onready var trashcan: Sprite2D = trashcanObject.get_child(0)
@onready var eraser: Sprite2D = eraserObject.get_child(0)
@onready var upgrade1: Sprite2D = upgrade1Object.get_child(0)
@onready var upgrade2: Sprite2D = upgrade2Object.get_child(0)
@onready var upgrade3: Sprite2D = upgrade3Object.get_child(0)
@onready var upgrade4: Sprite2D = upgrade4Object.get_child(0)
@onready var upgrade5: Sprite2D = upgrade5Object.get_child(0)

func _ready() -> void:
	setInitialStateOfObjects()




func setInitialStateOfObjects() -> void:
	var viewport_size = get_viewport_rect().size
	
	topPanelObject.position.x = viewport_size.x / 2
	topPanel.size.x = viewport_size.x
	topPanel.position.x = -topPanel.size.x / 2
	
	leftPanelObject.position.y = viewport_size.y / 2 + (topPanel.size.y / 2)
	leftPanel.size.y = viewport_size.y - topPanel.size.y
	leftPanel.position.y = -leftPanel.size.y / 2
	
	moneyLabelObject.position.x = viewport_size.x - (moneyLabel.size.x / 2) - 10
	moneyLabel.position.x = -moneyLabel.size.x / 2
	#moneyLabel.text = "Vertices:\n" + formatMoney(GameManager.money, GameManager.notationStyle)
	
	trashcanObject.position.y = viewport_size.y - (trashcan.texture.get_size().y / 2) - 4
	eraserObject.position.y = viewport_size.y - (eraser.texture.get_size().y * 1.25 / 2) - 7
	
	upgrade1Object.position.y = viewport_size.y / 2 + (topPanel.size.y / 2) - 133 + (upgrade1.texture.get_size().y / 2) + 4
	upgrade2Object.position.y = upgrade1Object.position.y
	upgrade3Object.position.y = upgrade1Object.position.y + upgrade1.texture.get_size().y + 4
	upgrade4Object.position.y = upgrade3Object.position.y
	upgrade5Object.position.y = upgrade3Object.position.y + upgrade1.texture.get_size().y + 4
