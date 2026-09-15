extends Control


const SHAPE: PackedScene = preload("uid://5qtpdede8o7j")
const DOT: PackedScene = preload("uid://dm2ovexatbsw")
const LINE: PackedScene = preload("uid://c8qhdkcnfwhm0")
const TRIANGLE: PackedScene = preload("uid://dxk2fgmtj8aow")
const SQUARE: PackedScene = preload("uid://njpjv407np8k")
const PENTAGON: PackedScene = preload("uid://q02suct8nroa")
const HEXAGON: PackedScene = preload("uid://d0iur6id8k8mg")
const HEPTAGON: PackedScene = preload("uid://cqdpu0x11qw61")
const OCTAGON: PackedScene = preload("uid://cie70mhpf51t1")

const GRID_SLOT_BUTTON: PackedScene = preload("uid://dvinbarfymwhy")

@export var gridSize: int = 3:
	set(value):
		gridSize = value
		updateGrid()

@onready var shapeButton: Button = $Button
@onready var dotButton: Button = $Shapes/HBoxContainer1/Dot
@onready var lineButton: Button = $Shapes/HBoxContainer1/Line
@onready var triangleButton: Button = $Shapes/HBoxContainer1/Triangle
@onready var squareButton: Button = $Shapes/HBoxContainer1/Square
@onready var pentagonButton: Button = $Shapes/HBoxContainer2/Pentagon
@onready var hexagonButton: Button = $Shapes/HBoxContainer2/Hexagon
@onready var heptagonButton: Button = $Shapes/HBoxContainer2/Heptagon
@onready var octagonButton: Button = $Shapes/HBoxContainer2/Octagon

@onready var gridContainer: GridContainer = $MarginContainer/GridContainer

var shapeHeldByCursor: Node2D
var gridButtons: Array
var gridStorage: Array[Dictionary]


@onready var moneyManager = $"../Money/Money Manager"

func _ready() -> void:
	shapeButton.button_down.connect(_on_shape_button_press.bind(SHAPE))
	dotButton.button_down.connect(_on_shape_button_press.bind(DOT))
	lineButton.button_down.connect(_on_shape_button_press.bind(LINE))
	triangleButton.button_down.connect(_on_shape_button_press.bind(TRIANGLE))
	squareButton.button_down.connect(_on_shape_button_press.bind(SQUARE))
	pentagonButton.button_down.connect(_on_shape_button_press.bind(PENTAGON))
	hexagonButton.button_down.connect(_on_shape_button_press.bind(HEXAGON))
	heptagonButton.button_down.connect(_on_shape_button_press.bind(HEPTAGON))
	octagonButton.button_down.connect(_on_shape_button_press.bind(OCTAGON))
	updateGrid()


func _process(_delta: float) -> void:
	if shapeHeldByCursor:
		shapeHeldByCursor.global_position = get_global_mouse_position()	

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("Left Click"):
		if shapeHeldByCursor:
			if getSlotInStorageByShape(shapeHeldByCursor) == null:
				print("cancel")
				shapeHeldByCursor.queue_free()
			else:
				print("delete")
				removeShapeFromStorage(shapeHeldByCursor)
				shapeHeldByCursor.queue_free()
				

func _on_shape_button_press(shapeScene: PackedScene) -> void:
	if shapeHeldByCursor:
		return
		
	var newShape = shapeScene.instantiate()
	shapeHeldByCursor = newShape
	add_child(newShape)


func _on_grid_button_pressed(gridButton: Button, slot: int) -> void:
	
	if shapeHeldByCursor and not getShapeInStorageBySlot(slot):
		if getSlotInStorageByShape(shapeHeldByCursor) == null:
			print("place")
			if moneyManager.money >= shapeHeldByCursor.cost:
				moneyManager.removeMoney(shapeHeldByCursor.cost)
			else:
				print("You are poor")
				shapeHeldByCursor.queue_free()
				return
			addShapeToStorage(slot, shapeHeldByCursor)
		else:
			print("move")
			removeShapeFromStorage(shapeHeldByCursor)
			addShapeToStorage(slot, shapeHeldByCursor)
		
		shapeHeldByCursor.reparent(gridButton)
		shapeHeldByCursor.global_position = gridButton.global_position + Vector2(16, 16)
		shapeHeldByCursor = null
		
	elif shapeHeldByCursor and getShapeInStorageBySlot(slot) == shapeHeldByCursor:
		print("place back")
		
		shapeHeldByCursor.reparent(gridButton)
		shapeHeldByCursor.global_position = gridButton.global_position + Vector2(16, 16)
		shapeHeldByCursor = null
		
	elif not shapeHeldByCursor and getShapeInStorageBySlot(slot):
		print("pickup")
		
		getShapeInStorageBySlot(slot).reparent(self)
		shapeHeldByCursor = getShapeInStorageBySlot(slot)


func addShapeToStorage(slot: int, shape: Node2D) -> void:
	gridStorage.append({"slot": slot,"shape": shape})

func removeShapeFromStorage(shape: Node2D) -> void:
	for dict in gridStorage:
		if dict["shape"] == shape:
			gridStorage.erase(dict)
			return

func removeShapeFromStorageSlot(slot: int) -> void:
	for dict in gridStorage:
		if dict["slot"] == slot:
			gridStorage.erase(dict)
			return

func getShapeInStorageBySlot(slot: int) -> Node2D:
	for dict in gridStorage:
		if dict["slot"] == slot:
			return dict["shape"]
	return null

func getSlotInStorageByShape(shape: Node2D):
	for dict in gridStorage:
		if dict["shape"] == shape:
			return dict["slot"]
	return null


func updateGrid() -> void:
	if not gridContainer:
		print("No grid container")
		return
	if gridSize < 1:
		push_error("Grid size cannot be smaller than 1")
		return
	
	var buttonsInGrid = gridContainer.get_children()
	var currentAmountOfButtons = buttonsInGrid.size()
	var totalButtonAmountNeeded = gridSize * gridSize
	
	if currentAmountOfButtons == totalButtonAmountNeeded:
		return
	
	var amountOfButtonsToAdd = 0
	if currentAmountOfButtons == 0:
		amountOfButtonsToAdd = totalButtonAmountNeeded
	elif currentAmountOfButtons < totalButtonAmountNeeded:
		amountOfButtonsToAdd = totalButtonAmountNeeded - currentAmountOfButtons
	else:
		#Code for downgrading grid?
		return
	
	for i in range(amountOfButtonsToAdd):
		var newButton = GRID_SLOT_BUTTON.instantiate()
		gridContainer.add_child(newButton)
		newButton.button_down.connect(_on_grid_button_pressed.bind(newButton, gridContainer.get_children().find(newButton)))
	
	gridContainer.columns = gridSize
	gridButtons = gridContainer.get_children()
