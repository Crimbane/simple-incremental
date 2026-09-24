extends Control


@export_file("*.tscn") var gamePath: String

@onready var movingShapes = %MovingShapes
@onready var startGameButton = %StartGame
@onready var settingsButton = %Settings
@onready var quitGameButton = %QuitGame



func _ready() -> void:
	startGameButton.pressed.connect(startGame)
	settingsButton.pressed.connect(settings)
	quitGameButton.pressed.connect(quitGame)

func _process(_delta: float) -> void:
	movingShapes.position = -get_local_mouse_position() * 0.02 + (get_viewport_rect().size / 2)
	var shapes = movingShapes.get_children()
	for shape in shapes:
		if shapes.find(shape) > 0 and shapes.find(shape) < int(shapes.size()/2.0):
			shape.rotation += randf_range(0.0005, 0.002)
		else:
			shape.rotation -= randf_range(0.0005, 0.002)



func startGame() -> void:
	get_tree().change_scene_to_file(gamePath)

func settings() -> void:
	pass

func quitGame() -> void:
	get_tree().quit()
