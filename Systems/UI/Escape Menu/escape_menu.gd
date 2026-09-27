extends Control


@onready var mainEscapeMenu: PanelContainer = %MainEscapeMenu
@onready var settingsMenu: PanelContainer = %SettingsMenu
@onready var notationDropdown: PanelContainer = %NotationDropdown
@export var resumeButton: Button


func _ready() -> void:
	resumeButton.pressed.connect(closeMenu)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("Escape") and not visible:
		visible = true
		
		# Set everything to default state:
		mainEscapeMenu.visible = true
		settingsMenu.visible = false
		notationDropdown.visible = false
	elif event.is_action_pressed("Escape") and visible:
		visible = false


func closeMenu() -> void:
	visible = false
