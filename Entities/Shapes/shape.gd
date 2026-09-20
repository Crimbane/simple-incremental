class_name Shape
extends Node2D

enum ShapeSprite {
	Dot = 1,
	Line = 2,
	Triangle = 3,
	Square = 4,
	Pentagon = 5,
	Hexagon = 6, 
	Heptagon = 7,
	Octagon= 8
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


func getShapeValue() -> int:
	var baseValue: int = shapeSprite
	return baseValue * GameManager.StateInfo[GameManager.currentState].ColorMultiplier
