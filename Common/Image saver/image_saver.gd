extends Node

# Change SubViewport size to desired image size and place desired image under it
# Remember to change file name

@onready var viewport = $SubViewport

func _ready() -> void:
	await get_tree().create_timer(1.0).timeout
	saveImage()

func saveImage() -> void:
	var texture = viewport.get_texture()
	var image = texture.get_image()
	
	# Change file name
	image.save_png("res://imageName.png")
	
	print("image saved to root")
	
	get_tree().quit()
