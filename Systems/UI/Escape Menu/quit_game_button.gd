extends Button




func _ready() -> void:
	pressed.connect(quitGame)
	
	mouse_entered.connect(SoundManager.playMenuButtonHoverSound)


func quitGame() -> void:
	# Add code to save game
	
	SoundManager.playMenuButtonClickSound()
	get_tree().quit()
