extends Label

var moneyLabel = GameManager.UIManager.moneyLabel

func showPopup(popupText: String, popupPosition: Vector2, type: String) -> void:
	text = popupText
	
	var tween = create_tween()
	tween.set_parallel(true)
	
	global_position = popupPosition
	
	if type == "Multiplier":
		var targetPosition = moneyLabel.global_position - Vector2(40,-30)
		tween.tween_property(self, "global_position", targetPosition, 1.0)
		tween.tween_property(self, "modulate:a", 0.0, 11)
		await get_tree().create_timer(1.0).timeout
		modulate = Color("#ff8184")
	
	else:
		tween.tween_property(self, "global_position", global_position + Vector2(0, -50), 0.8)
		tween.tween_property(self, "modulate:a", 0.0, 0.8)
	
	tween.finished.connect(queue_free)
