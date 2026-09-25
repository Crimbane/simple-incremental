extends Button

@export var notationStyle: GameManager.NotationStyle

func _ready() -> void:
	button_down.connect(selectNotation)


func selectNotation() -> void:
	GameManager.notationStyle = notationStyle
