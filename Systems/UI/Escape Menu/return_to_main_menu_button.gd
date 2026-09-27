extends Button



func _ready() -> void:
	pressed.connect(toMainMenu)


func toMainMenu() -> void:
	# Add code to save game
	
	SoundManager.playMainMenuButtonSound()
	SoundManager.playMenuMusic()
	get_tree().change_scene_to_file(GameManager.MAIN_MENU)
