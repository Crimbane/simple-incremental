extends Button


func _ready() -> void:
	button_down.connect(GameManager.rebirth)

func _process(_delta: float) -> void:
	var threshold = GameManager.StateInfo[GameManager.currentState].NextRebirthAvailabilityThreshold
	if GameManager.money < threshold and visible == true:
		visible = false
	elif GameManager.money >= threshold and visible == false:
		visible = true
