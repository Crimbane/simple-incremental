extends Button



func _ready() -> void:
	pressed.connect(toMainMenu)
	
	mouse_entered.connect(SoundManager.playMenuButtonHoverSound)


func toMainMenu() -> void:
	# Add code to save game
	
	SoundManager.playMenuButtonClickSound()
	SoundManager.playMenuMusic()
	get_tree().change_scene_to_file(GameManager.MAIN_MENU)
