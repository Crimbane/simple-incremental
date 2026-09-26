extends Node2D

@onready var topPanelObject: Node2D = $TopPanel
@onready var leftPanelObject: Node2D = $LeftPanel
@onready var moneyLabelObject: Node2D = $MoneyLabel
@onready var trashcanObject: Node2D = $Trashcan
@onready var eraserObject: Node2D = $Eraser
@onready var upgradesObject: Node2D = $Upgrades
@onready var gridObject: Node2D = $Grid
@onready var bigShape: Node2D = $Bishape

@onready var topPanel: Control = topPanelObject.get_child(0)
@onready var leftPanel: Control = leftPanelObject.get_child(0)
@onready var moneyLabel: Control = moneyLabelObject.get_child(0)
@onready var trashcan: Sprite2D = trashcanObject.get_child(0)
@onready var eraser: Sprite2D = eraserObject.get_child(0)

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
	
	upgradesObject.position.y = viewport_size.y / 2 + (topPanel.size.y / 2) - 133 + 4
	
	gridObject.position.y = viewport_size.y / 2 + (topPanel.size.y / 2)
	bigShape.position.y = viewport_size.y / 2 + (topPanel.size.y / 2)
	bigShape.position.x = (viewport_size.x - (leftPanel.size.x + 266)) / 2 + (leftPanel.size.x + 266)
