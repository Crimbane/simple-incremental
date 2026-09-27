extends Button


@onready var mainEscapeMenu: PanelContainer = %MainEscapeMenu
@onready var settingsMenu: PanelContainer = %SettingsMenu


func _ready() -> void:
	pressed.connect(closeSettings)
	
	mouse_entered.connect(SoundManager.playMenuButtonHoverSound)


func closeSettings() -> void:
	settingsMenu.visible = false
	mainEscapeMenu.visible = true
	SoundManager.playMenuButtonClickSound()
