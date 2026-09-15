extends Button

@export var shape: PackedScene

func _ready() -> void:
	button_down.connect(_on_shape_button_press)


func _on_shape_button_press() -> void:
	if UIManager.shapeHeldByCursor:
		return
		
	var newShape = shape.instantiate()
	UIManager.addShapeToCursor(newShape)
	add_child(newShape)
