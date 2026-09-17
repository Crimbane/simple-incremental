class_name Shape
extends Node2D

@export_enum(
	"Dot", "Line", "Triangle", "Square", "Pentagon", "Hexagon", 
	"Heptagon", "Octagon") var shapeSprite: String = "Dot":
	set(value):
		shapeSprite = value
		updateSprite()

@export var cost: int = 10

var isPurchaseShape: bool = false
var isGhostShape: bool = false:
	set(value):
		isGhostShape = value
		makeGhostShape()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	updateSprite()
	updateColor()


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
	
	var shapeColor: String = GameManager.shapeColor
	
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


func getColorMultiplier() -> int:
	match GameManager.shapeColor:
		"White":
			return 1
		"Red":
			return 2
		"Orange":
			return 4
		"Yellow":
			return 8
		"Green":
			return 16
		"Blue":
			return 32
		"Purple":
			return 64
		"Black":
			return 128
	
	return 1


func getShapeValue() -> int:
	var baseValue: int
	match shapeSprite:
		"Dot":
			baseValue = 1
		"Line":
			baseValue = 2
		"Triangle":
			baseValue = 3
		"Square":
			baseValue = 4
		"Pentagon":
			baseValue = 5
		"Hexagon":
			baseValue = 6
		"Heptagon":
			baseValue = 7
		"Octagon":
			baseValue = 8
	
	return baseValue * getColorMultiplier()


func makeGhostShape():
	if not isGhostShape:
		return
	
	var animatedSprite: AnimatedSprite2D = get_node_or_null("AnimatedSprite2D")
	animatedSprite.modulate = Color(1.0, 1.0, 1.0, 0.25)
