extends Node2D

@onready var topPanelObject: Node2D = $TopPanel
@onready var leftPanelObject: Node2D = $LeftPanel
@onready var moneyLabelObject: Node2D = $MoneyLabel
@onready var trashcanObject: Node2D = $Trashcan
@onready var eraserObject: Node2D = $Eraser
@onready var upgradesObject: Node2D = $Upgrades
@onready var shapeButtonsObject: Node2D = $ShapeButtons
@onready var gridObject: Node2D = $Grid
@onready var bigShape: Node2D = $Bishape

@onready var topPanel: Control = topPanelObject.get_child(0)
@onready var leftPanel: Control = leftPanelObject.get_child(0)
@onready var moneyLabel: Control = moneyLabelObject.get_child(0)
@onready var trashcan: Sprite2D = trashcanObject.get_child(0)
@onready var eraser: Sprite2D = eraserObject.get_child(0)

@onready var upgradeButtons = upgradesObject.get_children()
@onready var shapeButtons = shapeButtonsObject.get_children()
@onready var gridSlots = gridObject.get_children()

@onready var credits: Node2D = $Credits

var money = GameManager.money

func _ready() -> void:
	setInitialStateOfObjects()
	startEndSequence()

func _process(_delta: float) -> void:
	pass
	#money -= 1
	#moneyLabel.text = "Vertices:\n" + formatMoney(money, GameManager.notationStyle)


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
	#moneyLabel.text = "Vertices:\n" + formatMoney(money, GameManager.notationStyle)
	
	trashcanObject.position.y = viewport_size.y - (trashcan.texture.get_size().y / 2) - 4
	eraserObject.position.y = viewport_size.y - (eraser.texture.get_size().y * 1.25 / 2) - 7
	
	upgradesObject.position.y = viewport_size.y / 2 + (topPanel.size.y / 2) - 133 + 4
	
	gridObject.position.y = viewport_size.y / 2 + (topPanel.size.y / 2)
	#for shape in GameManager.gridStorage:
		#for slot in gridSlots:
			#if shape["slot"] == gridSlots.find(slot):
				#var icon: AnimatedSprite2D = slot.get_child(0).get_child(0)
				#var dropShadow: AnimatedSprite2D = icon.get_child(0)
				#icon.animation = GameManager.ShapeType.find_key(shape["shape"].shapeSprite).to_lower()
				#dropShadow.animation = GameManager.ShapeType.find_key(shape["shape"].shapeSprite).to_lower()
	
	bigShape.position.y = viewport_size.y / 2 + (topPanel.size.y / 2)
	bigShape.position.x = (viewport_size.x - (leftPanel.size.x + 266)) / 2 + (leftPanel.size.x + 266)
	bigShape.get_child(0).emission_ring_inner_radius = 100
	bigShape.get_child(0).emission_ring_radius = 100
	
	credits.position = viewport_size / 2
	credits.scale = Vector2(0.0, 0.0)


func startEndSequence() -> void:
	var tweenParticles = create_tween()
	tweenParticles.tween_property(bigShape.get_child(0), "emission_ring_inner_radius", 128.0, 2)
	tweenParticles.parallel().tween_property(bigShape.get_child(0), "emission_ring_radius", 132.0, 2)
	tweenParticles.parallel().tween_property(bigShape.get_child(0), "scale_amount_max", 10.0, 5)
	
	var tweenBigShape = create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	tweenBigShape.tween_property(bigShape, "global_position", get_viewport_rect().size / 2, 8)
	tweenBigShape.parallel().tween_property(bigShape, "rotation", 5.0, 8)
	tweenBigShape.parallel().tween_property(bigShape.get_child(1).get_child(0), "rotation", -10, 8)
	tweenBigShape.parallel().tween_property(bigShape, "scale", Vector2(5.0, 5.0), 8)
	
	
	
	for slot: Node2D in gridSlots:
		var distance = slot.global_position.distance_to(bigShape.global_position) / 80
		var tween = create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
		tween.tween_property(slot,
		"global_position",
		bigShape.global_position + Vector2(randf_range(20.0, -20.0),randf_range(10.0, -10.0)),
		distance + randf_range(0.0, 1.0))
		tween.parallel().tween_property(slot, "rotation", randf_range(-10.0, 10.0), distance + randf_range(-1.0, 1.0))
		tween.parallel().tween_property(slot, "skew", randf_range(-1.0, 1.0), distance + randf_range(-1.0, 1.0))
		tween.parallel().tween_property(slot, "scale", Vector2(0.0, 0.0), distance)
	
	for button: Node2D in upgradeButtons:
		var distance = button.global_position.distance_to(bigShape.global_position) / 80
		var tween = create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
		tween.tween_property(button,
		"global_position",
		bigShape.global_position + Vector2(randf_range(20.0, -20.0),randf_range(10.0, -10.0)),
		distance + randf_range(0.0, 1.0))
		tween.parallel().tween_property(button, "rotation", randf_range(-10.0, 10.0), distance + randf_range(-1.0, 1.0))
		tween.parallel().tween_property(button, "skew", randf_range(-1.0, 1.0), distance + randf_range(-1.0, 1.0))
		tween.parallel().tween_property(button, "scale", Vector2(0.0, 0.0), distance)
	
	for button: Node2D in shapeButtons:
		var distance = button.global_position.distance_to(bigShape.global_position) / 80
		var tween = create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
		tween.tween_property(button,
		"global_position",
		bigShape.global_position + Vector2(randf_range(20.0, -20.0),randf_range(10.0, -10.0)),
		distance + randf_range(0.0, 1.0))
		tween.parallel().tween_property(button, "rotation", randf_range(-10.0, 10.0), distance + randf_range(-1.0, 1.0))
		tween.parallel().tween_property(button, "skew", randf_range(-1.0, 1.0), distance + randf_range(-1.0, 1.0))
		tween.parallel().tween_property(button, "scale", Vector2(0.0, 0.0), distance)
	
	var distanceTrashcan = trashcanObject.global_position.distance_to(bigShape.global_position) / 80
	var tweenTrashcan  = create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	tweenTrashcan.tween_property(trashcanObject,
	"global_position",
	bigShape.global_position + Vector2(randf_range(20.0, -20.0),randf_range(10.0, -10.0)),
	distanceTrashcan + randf_range(0.0, 1.0))
	tweenTrashcan.parallel().tween_property(trashcanObject, "rotation", randf_range(-10.0, 10.0), distanceTrashcan + randf_range(-1.0, 1.0))
	tweenTrashcan.parallel().tween_property(trashcanObject, "skew", randf_range(-1.0, 1.0), distanceTrashcan + randf_range(-1.0, 1.0))
	tweenTrashcan.parallel().tween_property(trashcanObject, "scale", Vector2(0.0, 0.0), distanceTrashcan + randf_range(-1.0, 0.0))
	
	var distanceEraser = eraserObject.global_position.distance_to(bigShape.global_position) / 80
	var tweenEraser  = create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	tweenEraser.tween_property(eraserObject,
	"global_position",
	bigShape.global_position + Vector2(randf_range(20.0, -20.0),randf_range(10.0, -10.0)),
	distanceEraser + randf_range(0.0, 1.0))
	tweenEraser.parallel().tween_property(eraserObject, "rotation", randf_range(-10.0, 10.0), distanceEraser + randf_range(-1.0, 1.0))
	tweenEraser.parallel().tween_property(eraserObject, "skew", randf_range(-1.0, 1.0), distanceEraser + randf_range(-1.0, 1.0))
	tweenEraser.parallel().tween_property(eraserObject, "scale", Vector2(0.0, 0.0), distanceEraser + randf_range(-1.0, 0.0))
	
	var distanceMoney = moneyLabelObject.global_position.distance_to(bigShape.global_position) / 80
	var tweenMoney  = create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	tweenMoney.tween_property(moneyLabelObject,
	"global_position",
	bigShape.global_position + Vector2(randf_range(20.0, -20.0),randf_range(10.0, -10.0)),
	distanceMoney + randf_range(-1.0, 1.0))
	tweenMoney.parallel().tween_property(moneyLabelObject, "rotation", randf_range(-5.0, 5.0), distanceMoney + randf_range(-1.0, 1.0))
	tweenMoney.parallel().tween_property(moneyLabelObject, "skew", randf_range(-1.0, 1.0), distanceMoney + randf_range(-1.0, 1.0))
	tweenMoney.parallel().tween_property(moneyLabelObject, "scale", Vector2(0.0, 0.0), distanceMoney)
	
	var distanceTop = topPanelObject.global_position.distance_to(bigShape.global_position) / 50
	var tweenTop  = create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	tweenTop.tween_property(topPanelObject,
	"global_position",
	bigShape.global_position + Vector2(randf_range(20.0, -20.0),randf_range(10.0, -10.0)),
	distanceTop + randf_range(-1.0, 1.0))
	tweenTop.parallel().tween_property(topPanelObject, "rotation", randf_range(0.5, 1.0), distanceTop + randf_range(-1.0, 1.0))
	tweenTop.parallel().tween_property(topPanelObject, "skew", randf_range(-1.0, 1.0), distanceTop + randf_range(-1.0, 1.0))
	tweenTop.parallel().tween_property(topPanelObject, "scale", Vector2(0.0, 0.0), distanceTop)
	
	var distanceLeft = leftPanelObject.global_position.distance_to(bigShape.global_position) / 80
	var tweenLeft  = create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	tweenLeft.tween_property(leftPanelObject,
	"global_position",
	bigShape.global_position + Vector2(randf_range(20.0, -20.0),randf_range(10.0, -10.0)),
	distanceLeft + randf_range(-1.0, 1.0))
	tweenLeft.parallel().tween_property(leftPanelObject, "rotation", randf_range(1.0, 2.0), distanceLeft + randf_range(-1.0, 1.0))
	tweenLeft.parallel().tween_property(leftPanelObject, "skew", randf_range(-1.0, 1.0), distanceLeft + randf_range(-1.0, 1.0))
	tweenLeft.parallel().tween_property(leftPanelObject, "scale", Vector2(0.0, 0.0), distanceLeft + randf_range(-1.0, 0.0))
	
	await tweenBigShape.finished
	bigShape.get_child(1).get_child(0).visible = false
	var fadeTween = create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	fadeTween.tween_property(bigShape, "modulate:a", 0.0, 3)
	var creditTween = create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	creditTween.tween_property(credits, "scale", Vector2(1.0, 1.0), 4)
