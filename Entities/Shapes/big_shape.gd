extends Node2D

var bigShapeSprite: String = "Dot"

var rotationSpeed: float = 0.1



func _ready() -> void:
	GameManager.bigShape = self
	updateSprite()
	updateColor()


func _process(delta: float) -> void:
	rotation += rotationSpeed * delta


func updateSprite() -> void:
	var animatedSprite = get_node_or_null("Sprite")
	var dropShadow = get_node_or_null("Sprite/DropShadow")
	
	if animatedSprite == null or dropShadow == null:
		return
	
	bigShapeSprite = GameManager.bigShapeSprite
	animatedSprite.animation = bigShapeSprite.to_lower()
	dropShadow.animation = bigShapeSprite.to_lower()


func updateColor() -> void:
	var animatedSprite = get_node_or_null("Sprite")
	
	if animatedSprite == null:
		return
	
	animatedSprite.modulate = GameManager.StateInfo[GameManager.currentState].ColorRGB
