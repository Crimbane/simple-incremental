@tool
extends Node2D

@export_enum(
	"Dot", "Line", "Triangle", "Square", "Pentagon", "Hexagon", 
	"Heptagon", "Octagon") var shapeSprite: String = "Dot":
	set(value):
		shapeSprite = value
		updateSprite()

@export_enum(
	"White", "Red", "Orange", "Yellow",
	"Green", "Blue", "Purple", "Black") var shapeColor: String = "White":
	set(value):
		shapeColor = value
		updateColor()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	updateSprite()
	updateColor()
	
	print("Shape value: ", getShapeValue())


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func updateSprite() -> void:
	var animatedSprite = get_node_or_null("AnimatedSprite2D")
	
	if animatedSprite == null:
		return
	
	match shapeSprite:
		"Dot":
			animatedSprite.animation = "dot"
		"Line":
			animatedSprite.animation = "line"
		"Triangle":
			animatedSprite.animation = "triangle"
		"Square":
			animatedSprite.animation = "square"
		"Pentagon":
			animatedSprite.animation = "pentagon"
		"Hexagon":
			animatedSprite.animation = "hexagon"
		"Heptagon":
			animatedSprite.animation = "heptagon"
		"Octagon":
			animatedSprite.animation = "octagon"

func updateColor() -> void:
	var animatedSprite = get_node_or_null("AnimatedSprite2D")
	
	if animatedSprite == null:
		return
	
	match shapeColor:
		"White":
			animatedSprite.modulate = Color.WHITE
		"Red":
			animatedSprite.modulate = Color.RED
		"Orange":
			animatedSprite.modulate = Color.ORANGE
		"Yellow":
			animatedSprite.modulate = Color.YELLOW
		"Green":
			animatedSprite.modulate = Color.GREEN
		"Blue":
			animatedSprite.modulate = Color.BLUE
		"Purple":
			animatedSprite.modulate = Color.PURPLE
		"Black":
			animatedSprite.modulate = Color.BLACK


func getShapeValue() -> int:
	match shapeSprite:
		"Dot":
			return 1
		"Line":
			return 2
		"Triangle":
			return 3
		"Square":
			return 4
		"Pentagon":
			return 5
		"Hexagon":
			return 6
		"Heptagon":
			return 7
		"Octagon":
			return 8
	
	return 0
