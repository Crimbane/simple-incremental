extends Button


@export var tooltip: PanelContainer

func _ready() -> void:
	visible = false
	pressed.connect(GameManager.rebirth)
	button_up.connect(hideTooltip)

func _process(_delta: float) -> void:
	var threshold = GameManager.StateInfo[GameManager.currentState].NextRebirthAvailabilityThreshold
	if threshold > 0:
		if GameManager.money < threshold and visible and not GameManager.rebirthThresholdReached:
			visible = false
		elif GameManager.money >= threshold and not visible:
			SoundManager.playRebirthThresholdSound()
			GameManager.rebirthThresholdReached = true
			visible = true
	else:
		visible = false

func hideTooltip() -> void:
	tooltip.visible = false
