extends Node2D

@onready var area2D: Area2D = $Area2D

@export_enum(
	"Dot", "Line", "Triangle", "Square", "Pentagon",
	"Hexagon", "Heptagon", "Octagon") var starSprite: String = "Health":
	set(value):
		starSprite = value
		updateSprite()


var time: float = 0.0
var interval = 0.01
var maxSizeReached: bool = false
var maxSizeTimer: float = 1.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	updateSprite()
	area2D.input_event.connect(onArea2DInputEvent)
	scale = Vector2.ZERO

func _process(delta: float) -> void:
	time += delta
	
	if time > interval:
		time = 0
		if scale <= Vector2.ZERO:
			print("queue free")
			queue_free()
		if maxSizeReached:
			scaleDown()
			return
		if scale < Vector2(1,1):
			scaleUp()
		if scale >= Vector2(0.9,0.9):
			await get_tree().create_timer(maxSizeTimer).timeout
			maxSizeReached = true

func wish() -> void:
	var giftType: String
	var giftTypes = ["Money", "Multiplier"]
	giftType = giftTypes.pick_random()
	
	match giftType:
		"Money":
			var gift = randi_range(5, 15)
			GameManager.starMoneyGift(gift)
		"Multiplier":
			GameManager.starBuffActive = true
			GameManager.currentStarMultiplier = randf_range(1.0, 3)
			print("Star multiplier: ", GameManager.currentStarMultiplier)
			GameManager.starMultiplierTimer.start()
			GameManager.calculateMoneyIncrement()

func updateSprite() -> void:
	var animatedSprite = get_node_or_null("AnimatedSprite2D")
	if animatedSprite == null:
		return
	
	match starSprite:
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

func scaleUp() -> void:
	scale += Vector2(0.01, 0.01)

func scaleDown() -> void:
	scale -= Vector2(0.01, 0.01)

func onArea2DInputEvent(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		wish()
		queue_free()
