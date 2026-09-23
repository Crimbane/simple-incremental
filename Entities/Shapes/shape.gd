class_name Shape
extends Node2D

enum ShapeSprite {
	Dot,
	Line,
	Triangle,
	Square,
	Pentagon,
	Hexagon, 
	Heptagon,
	Octagon
}
@export var shapeSprite: ShapeSprite = ShapeSprite.Dot
@export var cost: int = 10

var isPurchaseShape: bool = false
var isGhostShape: bool = false:
	set(value):
		isGhostShape = value
		updateColor()

func _ready() -> void:
	updateSprite()
	updateColor()


func updateSprite() -> void:
	var animatedSprite = get_node_or_null("Sprite")
	var dropShadow = get_node_or_null("Sprite/DropShadow")
	
	if animatedSprite == null or dropShadow == null:
		return
	
	animatedSprite.animation = ShapeSprite.find_key(shapeSprite).to_lower()
	dropShadow.animation = ShapeSprite.find_key(shapeSprite).to_lower()

func updateColor() -> void:
	var animatedSprite = get_node_or_null("Sprite")
	var dropShadow = get_node_or_null("Sprite/DropShadow")
	
	if animatedSprite == null or dropShadow == null:
		return
	
	if isGhostShape:
		animatedSprite.modulate.a = 0.4
		dropShadow.visible = false
	else:
		animatedSprite.modulate = GameManager.StateInfo[GameManager.currentState].ColorRGB
		dropShadow.visible = true
		if GameManager.currentState == GameManager.State.Black:
			dropShadow.material.set_shader_parameter("blur_color", Color(1.0, 1.0, 1.0, 1.0))
			dropShadow.material.set_shader_parameter("blur_alpha", 4.0)


func getShapeValue() -> int:
	var baseValue: int = shapeSprite
	return baseValue * GameManager.StateInfo[GameManager.currentState].ColorMultiplier
