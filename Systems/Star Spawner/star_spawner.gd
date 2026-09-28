extends Node2D

var starScene = preload("uid://b2obby7d7gewo")

var time: float = 0.0
var baseSpawnTimer = 30
var spawnTimer: int = baseSpawnTimer

func _process(delta: float) -> void:
	time += delta
	
	if time >= spawnTimer:
		time = 0
		createClickableStar()
		spawnTimer = randomizeSpawnTimer(baseSpawnTimer)


func createClickableStar() -> void:
	var newStar = starScene.instantiate()
	
	var starTypes = ["Triangle", "Square", "Pentagon","Hexagon", "Heptagon", "Octagon"]
	newStar.starSprite = starTypes.pick_random()
	
	newStar.global_position = randomValidPosition()
	
	get_parent().call_deferred("add_child", newStar)

func randomValidPosition() -> Vector2:
	var viewportSize = get_viewport_rect().size
	var margin: int = 100
	
	var randomPositionX = randi_range(margin, viewportSize.x - margin)
	var randomPositionY = randi_range(margin, viewportSize.y - margin)
	
	var spawnArea = Vector2(randomPositionX, randomPositionY)
	return spawnArea

func randomizeSpawnTimer(timer) -> int:
	var timerOffset: int = 1
	var newSpawnTimer = randi_range(timer - timerOffset, timer + timerOffset)
	
	return newSpawnTimer
