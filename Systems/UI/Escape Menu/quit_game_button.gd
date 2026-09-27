extends Button




func _ready() -> void:
	pressed.connect(quitGame)


func quitGame() -> void:
	# Add code to save game
	
	get_tree().quit()
