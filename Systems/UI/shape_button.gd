extends Button

@export var shape: PackedScene
const BUTTON_BACKGROUND = preload("uid://dtndmfviqeq4d")



func _ready() -> void:
	button_down.connect(_on_shape_button_press)


func _on_shape_button_press() -> void:
	if GameManager.UIManager.shapeHeldByCursor:
		return
		
	var newShape: Shape = shape.instantiate()
	newShape.isPurchaseShape = true
	GameManager.UIManager.addShapeToCursor(newShape)
	GameManager.UIManager.add_child(newShape)
