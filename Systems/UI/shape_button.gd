@tool
extends Button


const BUTTON_BACKGROUND = preload("uid://dtndmfviqeq4d")
const SHAPE_SCENE: PackedScene = preload("uid://e1iphvwkj5db")

const DOT_TEXTURE: CompressedTexture2D = preload("uid://dlg50nillq8k1")
const LINE_TEXTURE: CompressedTexture2D = preload("uid://cg0dexsuih7l4")
const TRIANGLE_TEXTURE: CompressedTexture2D = preload("uid://dfmh6fcatyqp")
const SQUARE_TEXTURE: CompressedTexture2D = preload("uid://dxqco0xickmqf")
const PENTAGON_TEXTURE: CompressedTexture2D = preload("uid://c85vy0xr24igy")
const HEXAGON_TEXTURE: CompressedTexture2D = preload("uid://dbb0k618aw0ik")
const HEPTAGON_TEXTURE: CompressedTexture2D = preload("uid://hgy4pa7iuubv")
const OCTAGON_TEXTURE: CompressedTexture2D = preload("uid://c7102x3jjiyfl")

@export_enum(
	"Dot", "Line", "Triangle", "Square", "Pentagon", "Hexagon", 
	"Heptagon", "Octagon") var shape: String:
	set(value):
		shape = value
		updateIcon()

@export var cost: int = 10:
	set(value):
		cost = value

@onready var buttonIcon: TextureRect = $Icon


func _ready() -> void:
	button_down.connect(_on_shape_button_press)
	updateIcon()

func updateIcon() -> void:
	if not buttonIcon:
		return
	match shape:
		"Dot":
			buttonIcon.texture = DOT_TEXTURE
		"Line":
			buttonIcon.texture = LINE_TEXTURE
		"Triangle":
			buttonIcon.texture = TRIANGLE_TEXTURE
		"Square":
			buttonIcon.texture = SQUARE_TEXTURE
		"Pentagon":
			buttonIcon.texture = PENTAGON_TEXTURE
		"Hexagon":
			buttonIcon.texture = HEXAGON_TEXTURE
		"Heptagon":
			buttonIcon.texture = HEPTAGON_TEXTURE
		"Octagon":
			buttonIcon.texture = OCTAGON_TEXTURE

func _on_shape_button_press() -> void:
	if GameManager.UIManager.shapeHeldByCursor:
		return
		
	var newShape: Shape = SHAPE_SCENE.instantiate()
	newShape.shapeSprite = newShape.ShapeSprite[shape]
	newShape.cost = cost
	newShape.isPurchaseShape = true
	GameManager.UIManager.addShapeToCursor(newShape)
	GameManager.UIManager.add_child(newShape)
