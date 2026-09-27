extends Control


@onready var parallaxBackground: Node2D = %StarsBackground
@onready var parallaxMiddleground: Node2D = %StarsMiddleground
@onready var parallaxForeground: Node2D = %StarsForeground
@onready var parallaxMenu: Node2D = %EscapeMenuParallax
@onready var mainEscapeMenu: PanelContainer = %MainEscapeMenu
@onready var settingsMenu: PanelContainer = %SettingsMenu
@onready var notationDropdown: PanelContainer = %NotationDropdown
@export var resumeButton: Button


func _ready() -> void:
	resumeButton.pressed.connect(closeMenu)
	
	resumeButton.mouse_entered.connect(SoundManager.playMenuButtonHoverSound)

func _process(_delta: float) -> void:
	parallaxForeground.position = -get_local_mouse_position() * 0.04 + (get_viewport_rect().size / 2)
	parallaxMiddleground.position = -get_local_mouse_position() * 0.02 + (get_viewport_rect().size / 2)
	parallaxBackground.position = -get_local_mouse_position() * 0.01 + (get_viewport_rect().size / 2)
	if visible:
		parallaxMenu.position = -get_local_mouse_position() * 0.01 + (get_viewport_rect().size / 2)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("Escape") and not visible:
		visible = true
		
		# Set everything to default state:
		mainEscapeMenu.visible = true
		settingsMenu.visible = false
		notationDropdown.visible = false
	elif event.is_action_pressed("Escape") and visible:
		visible = false
	
	if event.is_action_pressed("Left Click") and notationDropdown.visible:
		notationDropdown.visible = false


func closeMenu() -> void:
	visible = false
	SoundManager.playMenuButtonClickSound()
