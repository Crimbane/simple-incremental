extends Button


@onready var mainEscapeMenu: PanelContainer = %MainEscapeMenu
@onready var settingsMenu: PanelContainer = %SettingsMenu


func _ready() -> void:
	pressed.connect(openSettings)


func openSettings() -> void:
	settingsMenu.visible = true
	mainEscapeMenu.visible = false
	SoundManager.playMainMenuButtonSound()
