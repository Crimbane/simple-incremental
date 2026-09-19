extends Button

@export var trashcanClosed: TextureRect
@export var trashcanOpen: TextureRect

var mouseInside: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	button_down.connect(clearShapeHeldByCursor)
	button_up.connect(onTrashcanButtonUp)
	mouse_entered.connect(onTrashcanMouseEntered)
	mouse_exited.connect(OnTrashcanMouseExited)

func onTrashcanMouseEntered():
	trashcanClosed.hide()
	trashcanOpen.show()
	mouseInside = true
	

func OnTrashcanMouseExited():
	trashcanOpen.hide()
	trashcanClosed.show()
	mouseInside = false

func onTrashcanButtonUp():
	if mouseInside == false:
		trashcanOpen.hide()
		trashcanClosed.show()
	else:
		trashcanClosed.hide()
		trashcanOpen.show()

func clearShapeHeldByCursor() -> void:
	var shapeHeldByCursor = GameManager.UIManager.shapeHeldByCursor
	if shapeHeldByCursor:
		GameManager.removeShapeFromStorage(shapeHeldByCursor)
		shapeHeldByCursor.queue_free()
		GameManager.calculateMoneyIncrement()
	
	if mouseInside == true:
		trashcanOpen.hide()
		trashcanClosed.show()
	else:
		trashcanClosed.hide()
		trashcanOpen.show()
