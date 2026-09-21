extends PanelContainer

@export var costLabel: Label
@export var textLabel: Label

@export_multiline var description: String

@onready var parent = $".."

@export_enum("Big Shape", "Rebirth", "Shape",) var parentType: String


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


func setDescription(text: String) -> void:
	textLabel.text = text

func setCost(cost: int) -> void:
	costLabel.text = "cost: " + str(cost)

func onMouseEntered() -> void:
	show()
	

func onMouseExited() -> void:
	hide()


func setBigShapeCost() -> void:
	if GameManager.currentBigShapeIndex >= GameManager.bigShapeNames.size() - 1:
		return
	
	var nextShape: String = GameManager.bigShapeNames[GameManager.currentBigShapeIndex + 1]
	setCost(GameManager.bigShapeDict[nextShape]["cost"])

func setRebirthCost() -> void:
	setCost(GameManager.StateInfo[GameManager.currentState].NextRebirthCost)

func setShapeCost() -> void:
	var currentCost = GameManager.getShapeCost(parent.cost, parent.shapeSprite + 1)
	setCost(currentCost)
	
	
