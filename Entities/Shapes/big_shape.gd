extends Node2D

var bigShapeSprite: String = "Octagon"

var rotationSpeed: float = 0.1



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	GameManager.bigShape = self
	updateSprite()
	updateColor()
	
	var viewport_size = get_viewport_rect().size
	position.x = viewport_size.x - 140
	position.y = viewport_size.y / 2


func _process(delta: float) -> void:
	rotation += rotationSpeed * delta


func updateSprite() -> void:
	var animatedSprite = get_node_or_null("AnimatedSprite2D")
	
	if animatedSprite == null:
		return
	
	animatedSprite.animation = bigShapeSprite.to_lower()


func updateColor() -> void:
	var animatedSprite = get_node_or_null("AnimatedSprite2D")
	
	if animatedSprite == null:
		return
	
	var shapeColor: String = GameManager.shapeColor
	
	match shapeColor:
		"White": animatedSprite.modulate = Color.WHITE
		"Red": animatedSprite.modulate = Color.RED
		"Orange": animatedSprite.modulate = Color.ORANGE
		"Yellow": animatedSprite.modulate = Color.YELLOW
		"Green": animatedSprite.modulate = Color.GREEN
		"Blue": animatedSprite.modulate = Color.BLUE
		"Purple": animatedSprite.modulate = Color.PURPLE
		"Black": animatedSprite.modulate = Color.BLACK
