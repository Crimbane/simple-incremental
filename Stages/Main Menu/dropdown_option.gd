extends Button

@export var notationStyle: GameManager.NotationStyle

func _ready() -> void:
	button_down.connect(selectNotation)
	
	mouse_entered.connect(SoundManager.playMenuButtonHoverSound)


func selectNotation() -> void:
	GameManager.notationStyle = notationStyle
	SoundManager.playMenuButtonClickSound()
	GameManager.saveSettings()
