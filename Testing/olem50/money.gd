extends Control

@onready var verticesLabel: Label = $MarginContainer/Vertices
var vertices: float = 0.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var triangle: Button = $VBoxContainer/HBoxContainer1/Triangle



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	vertices += delta
	updateMoneyUI()


func updateMoneyUI() -> void:
	verticesLabel.text = "Vertices: " + str(int(vertices))
