extends Control


@onready var parallaxLayer1 = %ParallaxLayer1
@onready var parallaxLayer2 = %ParallaxLayer2
@onready var parallaxLayer3 = %ParallaxLayer3
@onready var shapes1 = parallaxLayer1.get_children()
@onready var shapes2 = parallaxLayer2.get_children()
@onready var shapes3 = parallaxLayer3.get_children()
@onready var mainMenuParallax = %MainMenuParallax
@onready var settingsParallax = %SettingsParallax

@onready var continueButton: Button = %Continue
@onready var newGameButton: Button = %NewGame
@onready var settingsButton: Button = %Settings
@onready var quitGameButton: Button = %QuitGame
@onready var backButton: Button = %Back

@onready var confirmationPanel: PanelContainer = $MainMenuParallax/ConfirmationPanel

@onready var conformationYes: Button = %Yes
@onready var confirmationNo: Button = %No



func _ready() -> void:
	if FileAccess.file_exists(GameManager.SAVE_PATH):
		continueButton.show()
	else:
		continueButton.hide()
	
	
	continueButton.pressed.connect(continueGame)
	newGameButton.pressed.connect(newGame)
	conformationYes.pressed.connect(startNewGame)
	confirmationNo.pressed.connect(hideConfirmation)
	settingsButton.pressed.connect(settings)
	quitGameButton.pressed.connect(quitGame)
	backButton.pressed.connect(backToMainMenu)
	
	
	
	
	continueButton.mouse_entered.connect(SoundManager.playMenuButtonHoverSound)
	newGameButton.mouse_entered.connect(SoundManager.playMenuButtonHoverSound)
	settingsButton.mouse_entered.connect(SoundManager.playMenuButtonHoverSound)
	quitGameButton.mouse_entered.connect(SoundManager.playMenuButtonHoverSound)
	backButton.mouse_entered.connect(SoundManager.playMenuButtonHoverSound)

func _process(_delta: float) -> void:
	animateMainMenu()


func animateMainMenu() -> void:
	parallaxLayer1.position = -get_local_mouse_position() * 0.04 + (get_viewport_rect().size / 2)
	parallaxLayer2.position = -get_local_mouse_position() * 0.02 + (get_viewport_rect().size / 2)
	parallaxLayer3.position = -get_local_mouse_position() * 0.01 + (get_viewport_rect().size / 2)
	if mainMenuParallax.visible == true:
		mainMenuParallax.position = -get_local_mouse_position() * 0.01 + (get_viewport_rect().size / 2) + Vector2(0.0, 60.0)
	else:
		settingsParallax.position = -get_local_mouse_position() * 0.01 + (get_viewport_rect().size / 2)
	
	for shape in shapes1:
		if shapes1.find(shape) > 0 and shapes1.find(shape) < int(shapes1.size()/2.0):
			shape.rotation += randf_range(0.0005, 0.002)
		else:
			shape.rotation -= randf_range(0.0005, 0.002)
	for shape in shapes2:
		if shapes2.find(shape) > 0 and shapes2.find(shape) < int(shapes2.size()/2.0):
			shape.rotation += randf_range(0.0005, 0.002)
		else:
			shape.rotation -= randf_range(0.0005, 0.002)
	for shape in shapes3:
		if shapes3.find(shape) > 0 and shapes3.find(shape) < int(shapes3.size()/2.0):
			shape.rotation += randf_range(0.0005, 0.002)
		else:
			shape.rotation -= randf_range(0.0005, 0.002)


func continueGame() -> void:
	SoundManager.playMenuButtonClickSound()
	SoundManager.playRandomTrack()
	GameManager.loadSaveFile()
	get_tree().change_scene_to_file(GameManager.GAME)

func newGame() -> void:
	if FileAccess.file_exists(GameManager.SAVE_PATH):
		confirmationPanel.show()
		return
	startNewGame()

func hideConfirmation() -> void:
	confirmationPanel.hide()

func startNewGame() -> void:
	GameManager.resetGame()
	
	get_tree().change_scene_to_file(GameManager.GAME)
	SoundManager.playMenuButtonClickSound()
	SoundManager.playRandomTrack()

func settings() -> void:
	mainMenuParallax.visible = false
	settingsParallax.visible = true
	SoundManager.playMenuButtonClickSound()

func quitGame() -> void:
	SoundManager.playMenuButtonClickSound()
	get_tree().quit()

func backToMainMenu() -> void:
	mainMenuParallax.visible = true
	settingsParallax.visible = false
	SoundManager.playMenuButtonClickSound()
