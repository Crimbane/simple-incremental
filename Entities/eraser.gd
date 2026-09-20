extends Node2D


@onready var sprite: Sprite2D = $Sprite
@onready var dropShadow: Sprite2D = $Sprite/DropShadow

var isGhostShape: bool = false:
	set(value):
		isGhostShape = value
		updateColor()

func updateColor() -> void:
	if not sprite and not dropShadow:
		return
	sprite.modulate = Color(1.0, 0.2, 0.2, 0.8)
	dropShadow.visible = false
