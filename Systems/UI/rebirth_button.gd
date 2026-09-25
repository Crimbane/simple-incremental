extends Button


@export var tooltip: PanelContainer

func _ready() -> void:
	pressed.connect(GameManager.rebirth)
	button_up.connect(hideTooltip)

func _process(_delta: float) -> void:
	var threshold = GameManager.StateInfo[GameManager.currentState].NextRebirthAvailabilityThreshold
	if GameManager.money < threshold and visible == true:
		visible = false
	elif GameManager.money >= threshold and visible == false:
		visible = true

func hideTooltip() -> void:
	tooltip.visible = false
