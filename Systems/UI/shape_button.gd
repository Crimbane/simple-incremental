extends Button

@export var shape: PackedScene


func _ready() -> void:
	button_down.connect(_on_shape_button_press)


func _on_shape_button_press() -> void:
	if GameManager.UIManager.shapeHeldByCursor:
		return
		
	var newShape = shape.instantiate()
	GameManager.UIManager.addShapeToCursor(newShape)
	GameManager.UIManager.add_child(newShape)
