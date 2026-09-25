extends Button


@onready var notationDropdown = %NotationDropdown
@onready var notationLabel = $NotationLabel

func _ready() -> void:
	pressed.connect(openDropdown)
	focus_exited.connect(closeDropdown)
	notationLabel.text = GameManager.NotationStyle.find_key(GameManager.notationStyle).capitalize()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("Left Click") and notationDropdown.visible:
		closeDropdown()


func openDropdown() -> void:
	notationDropdown.visible = true

func closeDropdown() -> void:
	await get_tree().process_frame
	notationLabel.text = GameManager.NotationStyle.find_key(GameManager.notationStyle).capitalize()
	notationDropdown.visible = false
