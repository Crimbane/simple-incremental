extends Node2D

var popupScene = preload("uid://b50vixnhv0wr0")
var particleScene = preload("uid://cyj20iw1ny8nn")
@export var starButton: Button

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

func _ready() -> void:
	updateSprite()
	starButton.pressed.connect(onStarClicked)
	scale = Vector2.ZERO

func _process(delta: float) -> void:
	time += delta
	
	if time > interval:
		time = 0
		if scale <= Vector2.ZERO:
			hide()
			await get_tree().create_timer(1.0).timeout
			queue_free()
		if maxSizeReached:
			scaleDown()
			return
		if scale < Vector2(1,1):
			scaleUp()
		if scale >= Vector2(0.9,0.9):
			await get_tree().create_timer(maxSizeTimer).timeout
			maxSizeReached = true

func wish() -> Dictionary:
	var giftType: String
	var giftTypes = ["Money", "Multiplier"]
	giftType = giftTypes.pick_random()
	
	match giftType:
		"Money":
			var gift = randi_range(5, 15)
			var moneyGift = GameManager.starMoneyGift(gift)
			var formattedGift = GameManager.formatMoney(moneyGift)
			return {"text": "+$" + str(formattedGift), "type": "Money"}
		"Multiplier":
			GameManager.currentStarMultiplier = randf_range(1.0, 3.0)
			applyRewardAfterDelay()
			return {"text": "x" + str(snapped(GameManager.currentStarMultiplier, 0.1)), "type": "Multiplier"}
	return {"text": "", "type": ""}

func applyRewardAfterDelay() -> void:
	await get_tree().create_timer(1.0).timeout
	GameManager.starBuffActive = true
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

func onStarClicked() -> void:
	var result = wish()
	SoundManager.playStarClickSound()
	showPopup(result.text, result.type)
	spawnParticles()
	queue_free()

func spawnParticles() -> void:
	var newParticles = particleScene.instantiate()
	newParticles.emitting = true
	newParticles.global_position = global_position
	get_parent().call_deferred("add_child", newParticles)

func showPopup(text: String, type: String) -> void:
	var popup = popupScene.instantiate()
	get_parent().add_child(popup)
	popup.showPopup(text, global_position, type)
