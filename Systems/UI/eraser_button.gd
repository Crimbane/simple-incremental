extends Button


const ERASER_SCENE: PackedScene = preload("uid://dhigqih41adct")

func _ready() -> void:
	button_down.connect(pickupEraser)

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("Right Click") and GameManager.UIManager.eraserHeldByCursor:
		GameManager.UIManager.eraserHeldByCursor.queue_free()
		visible = true


func pickupEraser() -> void:
	if GameManager.UIManager.shapeHeldByCursor:
		return
	
	visible = false
	var eraser: Node2D = ERASER_SCENE.instantiate()
	GameManager.UIManager.addEraserToCursor(eraser)
	GameManager.UIManager.add_child(eraser)
