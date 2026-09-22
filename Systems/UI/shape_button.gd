@tool
extends Button


const BUTTON_BACKGROUND = preload("uid://dtndmfviqeq4d")
const SHAPE_SCENE: PackedScene = preload("uid://e1iphvwkj5db")

const ICON_TEXTURE: Dictionary[String, CompressedTexture2D] = {
	DOT = preload("uid://dlg50nillq8k1"),
	LINE = preload("uid://cg0dexsuih7l4"),
	TRIANGLE = preload("uid://dfmh6fcatyqp"),
	SQUARE = preload("uid://dxqco0xickmqf"),
	PENTAGON = preload("uid://c85vy0xr24igy"),
	HEXAGON = preload("uid://dbb0k618aw0ik"),
	HEPTAGON = preload("uid://hgy4pa7iuubv"),
	OCTAGON = preload("uid://c7102x3jjiyfl")
}

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

@export var shapeSprite: ShapeSprite = ShapeSprite.Dot:
	set(value):
		shapeSprite = value
		updateIcon()

@export var cost: int = 10:
	set(value):
		cost = value

@onready var buttonIcon: TextureRect = $Icon
@onready var dropShadow: TextureRect = $Icon/DropShadow




func _ready() -> void:
	button_down.connect(_on_shape_button_press)
	updateIcon()
	updateVisibility()

func _process(_delta: float) -> void:
	#updateVisibility()
	pass
func updateIcon() -> void:
	if not buttonIcon or not dropShadow:
		return
	buttonIcon.texture = ICON_TEXTURE[ShapeSprite.find_key(shapeSprite).to_upper()]
	dropShadow.texture = ICON_TEXTURE[ShapeSprite.find_key(shapeSprite).to_upper()]

func updateVisibility() -> void:
	if shapeSprite <= GameManager.highestUnlockedShapeButton:
		show()
	else:
		hide()
	

func _on_shape_button_press() -> void:
	if GameManager.UIManager.shapeHeldByCursor:
		return
		
	var newShape: Shape = SHAPE_SCENE.instantiate()
	newShape.shapeSprite = newShape.ShapeSprite[ShapeSprite.find_key(shapeSprite)]
	newShape.cost = GameManager.getShapeCost(cost, newShape.shapeSprite)
	newShape.isPurchaseShape = true
	GameManager.UIManager.addShapeToCursor(newShape)
	GameManager.UIManager.add_child(newShape)
