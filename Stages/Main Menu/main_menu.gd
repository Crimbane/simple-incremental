extends Control


@export_file("*.tscn") var gamePath: String

@onready var parallaxLayer1 = %ParallaxLayer1
@onready var parallaxLayer2 = %ParallaxLayer2
@onready var parallaxLayer3 = %ParallaxLayer3
@onready var shapes1 = parallaxLayer1.get_children()
@onready var shapes2 = parallaxLayer2.get_children()
@onready var shapes3 = parallaxLayer3.get_children()
@onready var mainMenuParallax = %MainMenuParallax
@onready var startGameButton = %StartGame
@onready var settingsButton = %Settings
@onready var quitGameButton = %QuitGame
@onready var settingsParallax = %SettingsParallax
@onready var backButton = %Back



func _ready() -> void:
	startGameButton.pressed.connect(startGame)
	settingsButton.pressed.connect(settings)
	quitGameButton.pressed.connect(quitGame)
	backButton.pressed.connect(backToMainMenu)

func _process(_delta: float) -> void:
	parallaxLayer1.position = -get_local_mouse_position() * 0.04 + (get_viewport_rect().size / 2)
	parallaxLayer2.position = -get_local_mouse_position() * 0.02 + (get_viewport_rect().size / 2)
	parallaxLayer3.position = -get_local_mouse_position() * 0.01 + (get_viewport_rect().size / 2)
	if mainMenuParallax.visible == true:
		mainMenuParallax.position = -get_local_mouse_position() * 0.01 + (get_viewport_rect().size / 2) + Vector2(0.0, 60.0)
	else:
		settingsParallax.position = -get_local_mouse_position() * 0.01 + (get_viewport_rect().size / 2) - Vector2(0.0, 1.0)
	
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



func startGame() -> void:
	get_tree().change_scene_to_file(gamePath)

func settings() -> void:
	mainMenuParallax.visible = false
	settingsParallax.visible = true

func quitGame() -> void:
	get_tree().quit()

func backToMainMenu() -> void:
	mainMenuParallax.visible = true
	settingsParallax.visible = false
