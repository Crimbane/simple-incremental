extends Button



func _ready() -> void:
	button_down.connect(get_tree().quit)
