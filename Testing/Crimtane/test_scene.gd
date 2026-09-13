extends Control


@onready var button: Button = $Button
@onready var grid: Array = $GridContainer.get_children()

const SHAPE: PackedScene = preload("uid://5qtpdede8o7j")

var cursorCarrySlot: Node2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	button.button_down.connect(_on_button_press)
	
	for slot in grid:
		slot.button_down.connect(_on_gridslot_pressed.bind(slot))


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if cursorCarrySlot:
		cursorCarrySlot.global_position = get_global_mouse_position()	

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("Left Click"):
		if cursorCarrySlot:
			print("cancel")
			cursorCarrySlot.queue_free()
				

func _on_button_press() -> void:
	if cursorCarrySlot:
		return
		
	var new_shape = SHAPE.instantiate()
	cursorCarrySlot = new_shape
	add_child(new_shape)


func _on_gridslot_pressed(gridslot: Button) -> void:
	if cursorCarrySlot and gridslot.get_children().size() == 0:
		print("place")
		cursorCarrySlot.reparent(gridslot)
		cursorCarrySlot.global_position = gridslot.global_position + Vector2(16, 16)
		cursorCarrySlot = null
