extends Button




func _ready() -> void:
	pressed.connect(quitGame)
	
	mouse_entered.connect(SoundManager.playMenuButtonHoverSound)


func quitGame() -> void:
	GameManager.saveGame()
	
	SoundManager.playMenuButtonClickSound()
	get_tree().quit()
