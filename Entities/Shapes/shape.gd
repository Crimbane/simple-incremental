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
	
	match shapeSprite:
		ShapeSprite.Dot:
			animatedSprite.animation = "dot"
			dropShadow.animation = "dot"
		ShapeSprite.Line:
			animatedSprite.animation = "line"
			dropShadow.animation = "line"
		ShapeSprite.Triangle:
			animatedSprite.animation = "triangle"
			dropShadow.animation = "triangle"
		ShapeSprite.Square:
			animatedSprite.animation = "square"
			dropShadow.animation = "square"
		ShapeSprite.Pentagon:
			animatedSprite.animation = "pentagon"
			dropShadow.animation = "pentagon"
		ShapeSprite.Hexagon:
			animatedSprite.animation = "hexagon"
			dropShadow.animation = "hexagon"
		ShapeSprite.Heptagon:
			animatedSprite.animation = "heptagon"
			dropShadow.animation = "heptagon"
		ShapeSprite.Octagon:
			animatedSprite.animation = "octagon"
			dropShadow.animation = "octagon"

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
	var baseValue: int
	match shapeSprite:
		ShapeSprite.Dot:
			baseValue = 1
		ShapeSprite.Line:
			baseValue = 2
		ShapeSprite.Triangle:
			baseValue = 3
		ShapeSprite.Square:
			baseValue = 4
		ShapeSprite.Pentagon:
			baseValue = 5
		ShapeSprite.Hexagon:
			baseValue = 6
		ShapeSprite.Heptagon:
			baseValue = 7
		ShapeSprite.Octagon:
			baseValue = 8
	
	return baseValue * GameManager.StateInfo[GameManager.currentState].ColorMultiplier
