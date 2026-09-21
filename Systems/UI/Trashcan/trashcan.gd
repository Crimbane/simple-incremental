extends Button

@export var trashcanClosed: TextureRect
@export var trashcanOpen: TextureRect
@export var confirmationPanel: Panel
@export var yesButton: Button
@export var noButton: Button

var mouseInside: bool = false
var mouseInsideConfirmation = false

func _ready() -> void:
	button_down.connect(clearShapeHeldByCursor)
	button_up.connect(onTrashcanButtonUp)
	mouse_entered.connect(onTrashcanMouseEntered)
	mouse_exited.connect(OnTrashcanMouseExited)
	yesButton.pressed.connect(deleteAllShapes)
	noButton.pressed.connect(hideConfirmation)
	focus_exited.connect(func(): if not mouseInsideConfirmation: hideConfirmation())
	confirmationPanel.mouse_entered.connect(func(): mouseInsideConfirmation = true)
	confirmationPanel.mouse_exited.connect(func(): mouseInsideConfirmation = false)



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
	var eraserHeldByCursor = GameManager.UIManager.eraserHeldByCursor
	if shapeHeldByCursor:
		GameManager.removeShapeFromStorage(shapeHeldByCursor)
		shapeHeldByCursor.queue_free()
		GameManager.calculateMoneyIncrement()
		
	elif not shapeHeldByCursor and not eraserHeldByCursor:
		if GameManager.gridStorage and not confirmationPanel.visible:
			confirmationPanel.visible = true
		
	
	if mouseInside == true:
		trashcanOpen.hide()
		trashcanClosed.show()
	else:
		trashcanClosed.hide()
		trashcanOpen.show()

func deleteAllShapes() -> void:
	confirmationPanel.visible = false
	for dict in GameManager.gridStorage.duplicate():
			GameManager.getShapeInStorageBySlot(dict["slot"]).queue_free()
			GameManager.removeShapeFromStorageSlot(dict["slot"])
			GameManager.calculateMoneyIncrement()

func hideConfirmation() -> void:
	confirmationPanel.visible = false
