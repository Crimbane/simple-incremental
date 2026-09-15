extends Control

@onready var moneyLabel: Label = $MarginContainer/Money

var money: int = 0
var time: float = 0.0
var interval: float = 1.0 # Seconds between increments
var incrementAmount: int = 1


func _ready() -> void:
	pass
	#var triangle: Button = $VBoxContainer/HBoxContainer1/Triangle



func _process(delta: float) -> void:
	time += delta
	
	if time > interval:
		time = 0
		money += incrementAmount
	
	updateMoneyUI()


func updateMoneyUI() -> void:
	moneyLabel.text = "Vertices: " + str(money)


func addMoney(amount: int) -> void:
	money += amount
	updateMoneyUI()


func removeMoney(amount: int) -> void:
	money -= amount
	updateMoneyUI()
