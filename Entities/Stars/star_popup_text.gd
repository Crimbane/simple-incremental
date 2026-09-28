extends Label


func showPopup(popupText: String, popupPosition: Vector2) -> void:
	text = popupText
	global_position = popupPosition
	
	var tween = create_tween()
	tween.set_parallel(true)
	
	tween.tween_property(self, "global_position", global_position + Vector2(0, -50), 0.8)
	
	tween.tween_property(self, "modulate:a", 0.0, 0.8)
	
	tween.finished.connect(queue_free)
