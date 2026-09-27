extends Node2D

var starScene = preload("uid://b2obby7d7gewo")

var time: float = 0.0
var interval = 30

func _process(delta: float) -> void:
	time += delta
	
	if time > interval:
		time = 0
		createClickableStar()


func createClickableStar() -> void:
	var newStar = starScene.instantiate()
	
	var starTypes = ["Triangle", "Square", "Pentagon","Hexagon", "Heptagon", "Octagon"]
	newStar.starSprite = starTypes.pick_random()
	
	newStar.global_position = randomValidPosition()
	
	get_parent().call_deferred("add_child", newStar)

func randomValidPosition() -> Vector2:
	var randomPosition: Vector2
	
	#var spawnArea = Vector2(0, 640), (0, 360)
	var spawnArea = Vector2(randf_range(0, 640), randf_range(0, 360))
	
	return spawnArea
