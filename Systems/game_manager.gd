extends Node


const GAME: String = "res://Stages/main.tscn"
const MAIN_MENU: String = "res://Stages/Main Menu/main_menu.tscn"
const END_SEQUENCE: String = "res://Stages/end_sequence.tscn"
const SHAPE_SCENE: PackedScene = preload("uid://e1iphvwkj5db")

@export var starMultiplierTimer: Timer
var starBuffActive: bool = false
var currentStarMultiplier: float = 1.0

const START_MONEY = 10#**18
const START_STATE = State.White
const START_BIG_SHAPE = ShapeType.Dot
const BASE_GRID_SIZE: int = 2
const BASE_INCREMENT_AMOUNT: int = 0
const BASE_INTERVAL: float = 1.0
const BASE_SHAPE_SYNERGY_MULTI: float = 0.2

enum NotationStyle { NONE, ABBREVIATION, SCIENTIFIC, ENGINEERING }
var notationStyle: NotationStyle = NotationStyle.ABBREVIATION

var money: int = START_MONEY
var time: float = 0.0
var interval: float = BASE_INTERVAL # Seconds between increments
var incrementAmount: int = BASE_INCREMENT_AMOUNT
var synergyUnlocked: bool = false
var synergyMulti: float = BASE_SHAPE_SYNERGY_MULTI
var gridSize: int = BASE_GRID_SIZE:
	set(value):
		gridSize = value
		if UIManager:
			UIManager.updateGrid()

#region Dictionary
enum State { White, Red, Orange, Yellow, Green, Blue, Purple, Black }
var StateInfo: Dictionary[State, StateData] = {
	State.White: StateData.new({
		ColorRGB = Color(0.9, 0.9, 0.9),
		ColorMultiplier = 1,
		NextRebirthCost = 500,
		NextRebirthAvailabilityThreshold = 400,
		MaxBigShapeLevel = 9,
		HighestUnlockedShapeButton = 0
	}),
	State.Red: StateData.new({
		ColorRGB = Color(0.8, 0.2, 0.2),
		ColorMultiplier = 8,
		NextRebirthCost = 25000,
		NextRebirthAvailabilityThreshold = 2500,
		MaxBigShapeLevel = 9,
		HighestUnlockedShapeButton = 1
	}),
	State.Orange: StateData.new({
		ColorRGB = Color(1.0, 0.5, 0.0),
		ColorMultiplier = 64,
		NextRebirthCost = 10000000,
		NextRebirthAvailabilityThreshold = 1000000,
		MaxBigShapeLevel = 9,
		HighestUnlockedShapeButton = 2
	}),
	State.Yellow: StateData.new({
		ColorRGB = Color(1.0, 0.8, 0.0),
		ColorMultiplier = 512,
		NextRebirthCost = 500000000,
		NextRebirthAvailabilityThreshold = 50000000,
		MaxBigShapeLevel = 9,
		HighestUnlockedShapeButton = 3
	}),
	State.Green: StateData.new({
		ColorRGB = Color(0.2, 0.7, 0.2),
		ColorMultiplier = 4096,
		NextRebirthCost = 25000000000,
		NextRebirthAvailabilityThreshold = 2500000000,
		MaxBigShapeLevel = 9,
		HighestUnlockedShapeButton = 4
	}),
	State.Blue: StateData.new({
		ColorRGB = Color(0.4, 0.5, 0.8),
		ColorMultiplier = 32768,
		NextRebirthCost = 500000000000,
		NextRebirthAvailabilityThreshold = 50000000000,
		MaxBigShapeLevel = 9,
		HighestUnlockedShapeButton = 5
	}),
	State.Purple: StateData.new({
		ColorRGB = Color(0.8, 0.2, 0.9),
		ColorMultiplier = 262144,
		NextRebirthCost = 12500000000000,
		NextRebirthAvailabilityThreshold = 1250000000000,
		MaxBigShapeLevel = 9,
		HighestUnlockedShapeButton = 6
	}),
	State.Black: StateData.new({
		ColorRGB = Color(0.1, 0.1, 0.1),
		ColorMultiplier = 4294967296,
		NextRebirthAvailabilityThreshold = -1,
		MaxBigShapeLevel = 10,
		HighestUnlockedShapeButton = 7
	})
}
var currentState: int = START_STATE

enum ShapeType { Dot, Line, Triangle, Square, Pentagon, Hexagon, Heptagon, Octagon, Nonagon, Decagon, Circle }
var ShapeInfo: Dictionary[ShapeType, ShapeData] = {
	ShapeType.Dot: ShapeData.new({
		ShapeMultiplier = 1,
		ShapeCost = 10,
		BigShapeMultiplier = 1,
		NextBigShapeCost = 100
	}),
	ShapeType.Line: ShapeData.new({
		ShapeMultiplier = 2,
		ShapeCost = 20,
		BigShapeMultiplier = 2,
		NextBigShapeCost = 5000
	}),
	ShapeType.Triangle: ShapeData.new({
		ShapeMultiplier = 3,
		ShapeCost = 30,
		BigShapeMultiplier = 3,
		NextBigShapeCost = 250000
	}),
	ShapeType.Square: ShapeData.new({
		ShapeMultiplier = 4,
		ShapeCost = 40,
		BigShapeMultiplier = 4,
		NextBigShapeCost = 10000000
	}),
	ShapeType.Pentagon: ShapeData.new({
		ShapeMultiplier = 5,
		ShapeCost = 50,
		BigShapeMultiplier = 5,
		NextBigShapeCost = 500000000
	}),
	ShapeType.Hexagon: ShapeData.new({
		ShapeMultiplier = 6,
		ShapeCost = 60,
		BigShapeMultiplier = 6,
		NextBigShapeCost = 25000000000
	}),
	ShapeType.Heptagon: ShapeData.new({
		ShapeMultiplier = 7,
		ShapeCost = 70,
		BigShapeMultiplier = 7,
		NextBigShapeCost = 1000000000000
	}),
	ShapeType.Octagon: ShapeData.new({
		ShapeMultiplier = 8,
		ShapeCost = 80,
		BigShapeMultiplier = 8,
		NextBigShapeCost = 50000000000000
	}),
	ShapeType.Nonagon: ShapeData.new({
		BigShapeMultiplier = 9,
		NextBigShapeCost = 500000000000000
	}),
	ShapeType.Decagon: ShapeData.new({
		BigShapeMultiplier = 10,
		NextBigShapeCost = 10**18 # 1 Quintillion / 1.0e18
	})
}
var currentBigShapeType: int = START_BIG_SHAPE

enum UpgradeType { Interval, Grid, SynergyUnlock, SynergyMulti }
var UpgradeInfo: Dictionary[UpgradeType, UpgradeData] = {
	UpgradeType.Interval: UpgradeData.new({
		CurrentLevel = 0,
		MaxLevel = 10,
		BaseCost = 250,
		NextLevelCost = 250,
		ExponentialCostIncrease = 4.5
	}),
	UpgradeType.Grid: UpgradeData.new({
		CurrentLevel = 0,
		MaxLevel = 6,
		BaseCost = 1000,
		NextLevelCost = 1000,
		ExponentialCostIncrease = 6
	}),
	UpgradeType.SynergyUnlock: UpgradeData.new({
		CurrentLevel = 0,
		MaxLevel = 1,
		BaseCost = 25000,
		NextLevelCost = 25000,
		ExponentialCostIncrease = 1
	}),
	UpgradeType.SynergyMulti: UpgradeData.new({
		CurrentLevel = 0,
		MaxLevel = 4,
		BaseCost = 250000,
		NextLevelCost = 250000,
		ExponentialCostIncrease = 10
	}),
}
#endregion

var gridStorage: Array[Dictionary]

var UIManager: Node = null
var bigShape: Node2D = null
var upgraded = false
var rebirthThresholdReached = false

const SAVE_PATH = "user://savegame.json"
const SETTINGS_PATH = "user://settings.json"

func _ready() -> void:
	loadSaveFile()
	loadSettingsFile()
	starMultiplierTimer.timeout.connect(onStarMultiplierTimerTimeout)

func _process(delta: float) -> void:
	time += delta
	
	if time > interval:
		time = 0
		money += incrementAmount


#region Money
func addMoney(amount: int) -> void:
	money += amount


func removeMoney(amount: int) -> void:
	money -= amount


func calculateMoneyIncrement() -> void:
	incrementAmount = BASE_INCREMENT_AMOUNT
	for dict in gridStorage:
		var shape = dict["shape"].shapeSprite
		var shapeValue = ShapeInfo[dict["shape"].shapeSprite].ShapeMultiplier
		var shapeSynergy = getShapeSynergyMulti(shape)
		
		var finalShapeValue = shapeValue * shapeSynergy
		
		incrementAmount += roundi(finalShapeValue)# * 10#playtesting number
	
	if currentBigShapeType != ShapeType.Circle:
		incrementAmount *= ShapeInfo[currentBigShapeType].BigShapeMultiplier
	
	incrementAmount *= StateInfo[currentState].ColorMultiplier
	
	var starMultiplier = starMultiplierGift()
	incrementAmount = roundi(incrementAmount * starMultiplier)
	
	print("incrementAmount: ", incrementAmount)

func getShapeCost(baseCost: int, shape: Shape.ShapeSprite) -> int:
	var count: int = getShapeCount(shape)
	
	return roundi(baseCost * pow(1.15, count))

func getShapeSynergyMulti(shape: Shape.ShapeSprite) -> float:
	if synergyUnlocked:
		var count: int = getShapeCount(shape - 4)
		
		var multiplier = 1.0 + (count * synergyMulti)
		print("getShapeSynergyMulti", synergyMulti)
		print("multiplier: ", multiplier)
		
		return multiplier
	else:
		return 1.0

func starMoneyGift(number: float) -> int:
	var moneyGift = incrementAmount * number
	money += int(moneyGift)
	return int(moneyGift)

func starMultiplierGift() -> float:
	if starBuffActive == true:
		return currentStarMultiplier
	
	return 1.0

func onStarMultiplierTimerTimeout() -> void:
	starBuffActive = false
	currentStarMultiplier = 1.0
	calculateMoneyIncrement()

#endregion


#region Upgrades
func rebirth() -> void:
	if currentState == State.Black:
		return
	if money < StateInfo[currentState].NextRebirthCost:
		SoundManager.playNoMoneySound()
		print("Not enough money")
		return
	
	removeMoney(StateInfo[currentState].NextRebirthCost)
	
	SoundManager.playRebirthSound()
	currentState += 1
	rebirthThresholdReached = false
	
	await UIManager.createPreRebirthScreenshot()
	
	bigShape.updateColor()
	UIManager.updateColor()
	UIManager.clearShapesInGrid()
	clearStorage()
	clearUpgrades()
	money = 10
	calculateMoneyIncrement()
	
	UIManager.playRebirthTransition(StateInfo[currentState].ColorRGB)
	saveGame()
	
	SoundManager.playBlackStateMusic()


func upgradeBigShape() -> void:
	var currentLevel: int = currentBigShapeType
	
	if currentBigShapeType == ShapeType.Circle:
		print("bigshape max level reached")
		return
	if currentLevel == StateInfo[currentState].MaxBigShapeLevel:
		print("current level == max level")
		return
	var cost: int = ShapeInfo[currentBigShapeType].NextBigShapeCost
	
	if money < cost:
		SoundManager.playNoMoneySound()
		print("Not enough money")
		return
	
	removeMoney(cost)
	
	currentBigShapeType += 1
	
	if currentBigShapeType == ShapeType.Decagon:
		UIManager.updateColor()
	
	bigShape.updateSprite()
	
	if currentBigShapeType == ShapeType.Circle:
		get_tree().change_scene_to_file(END_SEQUENCE)
		return
	
	print("upgraded big shape to ", ShapeType.find_key(currentBigShapeType))
	calculateMoneyIncrement()
	SoundManager.playUpgradeButtonSound()

func upgradeMoneyInterval() -> void:
	var cost: int = UpgradeInfo[UpgradeType.Interval].NextLevelCost
	var baseCost: int = UpgradeInfo[UpgradeType.Interval].BaseCost
	var costIncrease: float = UpgradeInfo[UpgradeType.Interval].ExponentialCostIncrease
	var currentLevel: int = UpgradeInfo[UpgradeType.Interval].CurrentLevel
	
	if interval <= 0.1 or currentLevel == UpgradeInfo[UpgradeType.Interval].MaxLevel:
		UpgradeInfo[UpgradeType.Interval].NextLevelCost = 0
		return
	
	if money < cost:
		SoundManager.playNoMoneySound()
		print("Not enough money")
		return
	removeMoney(cost)
	
	currentLevel += 1
	UpgradeInfo[UpgradeType.Interval].CurrentLevel = currentLevel
	
	var nextLevelCost = roundi(baseCost * pow(costIncrease, currentLevel))
	UpgradeInfo[UpgradeType.Interval].NextLevelCost = nextLevelCost
	
	interval -= 0.09
	
	if currentLevel == UpgradeInfo[UpgradeType.Interval].MaxLevel:
		SoundManager.playMaxUpgradeSound()
	else:
		SoundManager.playUpgradeButtonSound()

func upgradeGrid() -> void:
	var cost: int = UpgradeInfo[UpgradeType.Grid].NextLevelCost
	var baseCost: int = UpgradeInfo[UpgradeType.Grid].BaseCost
	var costIncrease: float = UpgradeInfo[UpgradeType.Grid].ExponentialCostIncrease
	var currentLevel: int = UpgradeInfo[UpgradeType.Grid].CurrentLevel
	
	if gridSize == 8 or currentLevel == UpgradeInfo[UpgradeType.Grid].MaxLevel:
		UpgradeInfo[UpgradeType.Grid].NextLevelCost = 0
		return
	
	if money < cost:
		SoundManager.playNoMoneySound()
		print("Not enough money")
		return
	removeMoney(cost)
	
	currentLevel += 1
	UpgradeInfo[UpgradeType.Grid].CurrentLevel = currentLevel
	
	var nextLevelCost = roundi(baseCost * pow(costIncrease, currentLevel))
	UpgradeInfo[UpgradeType.Grid].NextLevelCost = nextLevelCost
	
	gridSize += 1
	
	if currentLevel == UpgradeInfo[UpgradeType.Grid].MaxLevel:
		SoundManager.playMaxUpgradeSound()
	else:
		SoundManager.playUpgradeButtonSound()


func upgradeSynergyUnlock() -> void:
	var cost: int = UpgradeInfo[UpgradeType.SynergyUnlock].NextLevelCost
	var baseCost: int = UpgradeInfo[UpgradeType.SynergyUnlock].BaseCost
	var costIncrease: float = UpgradeInfo[UpgradeType.SynergyUnlock].ExponentialCostIncrease
	var currentLevel: int = UpgradeInfo[UpgradeType.SynergyUnlock].CurrentLevel
	
	if synergyUnlocked == true or currentLevel == UpgradeInfo[UpgradeType.SynergyUnlock].MaxLevel:
		UpgradeInfo[UpgradeType.SynergyUnlock].NextLevelCost = 0
		return
	
	if money < cost:
		SoundManager.playNoMoneySound()
		print("Not enough money")
		return
	removeMoney(cost)
	
	currentLevel += 1
	UpgradeInfo[UpgradeType.SynergyUnlock].CurrentLevel = currentLevel
	
	var nextLevelCost = roundi(baseCost * pow(costIncrease, currentLevel))
	UpgradeInfo[UpgradeType.SynergyUnlock].NextLevelCost = nextLevelCost
	
	synergyUnlocked = true
	SoundManager.playMaxUpgradeSound()


func upgradeSynergyMultiplier() -> void:
	var cost: int = UpgradeInfo[UpgradeType.SynergyMulti].NextLevelCost
	var baseCost: int = UpgradeInfo[UpgradeType.SynergyMulti].BaseCost
	var costIncrease: float = UpgradeInfo[UpgradeType.SynergyMulti].ExponentialCostIncrease
	var currentLevel: int = UpgradeInfo[UpgradeType.SynergyMulti].CurrentLevel
	
	if currentLevel == UpgradeInfo[UpgradeType.SynergyMulti].MaxLevel:
		UpgradeInfo[UpgradeType.SynergyMulti].NextLevelCost = 0
		return
	
	if money < cost:
		SoundManager.playNoMoneySound()
		print("Not enough money")
		return
	removeMoney(cost)
	
	currentLevel += 1
	UpgradeInfo[UpgradeType.SynergyMulti].CurrentLevel = currentLevel
	
	var nextLevelCost = roundi(baseCost * pow(costIncrease, currentLevel))
	UpgradeInfo[UpgradeType.SynergyMulti].NextLevelCost = nextLevelCost
	
	synergyMulti += 0.1
	
	if currentLevel == UpgradeInfo[UpgradeType.SynergyMulti].MaxLevel:
		SoundManager.playMaxUpgradeSound()
	else:
		SoundManager.playUpgradeButtonSound()


func clearUpgrades() -> void:
	gridSize = BASE_GRID_SIZE
	UpgradeInfo[UpgradeType.Grid].CurrentLevel = 0
	UpgradeInfo[UpgradeType.Grid].NextLevelCost = UpgradeInfo[UpgradeType.Grid].BaseCost
	
	interval = BASE_INTERVAL
	UpgradeInfo[UpgradeType.Interval].CurrentLevel = 0
	UpgradeInfo[UpgradeType.Interval].NextLevelCost = UpgradeInfo[UpgradeType.Interval].BaseCost
	
	currentBigShapeType = ShapeType.Dot
	bigShape.updateSprite()
	
	synergyUnlocked = false
	UpgradeInfo[UpgradeType.SynergyUnlock].CurrentLevel = 0
	UpgradeInfo[UpgradeType.SynergyUnlock].NextLevelCost = UpgradeInfo[UpgradeType.SynergyUnlock].BaseCost
	
	synergyMulti = BASE_SHAPE_SYNERGY_MULTI
	UpgradeInfo[UpgradeType.SynergyMulti].CurrentLevel = 0
	UpgradeInfo[UpgradeType.SynergyMulti].NextLevelCost = UpgradeInfo[UpgradeType.SynergyMulti].BaseCost
	
	UIManager.shapeButtons.propagate_call("updateVisibility")

#endregion


func unlockNextShapeButton(shape: int) -> void:
	var highestUnlockedShapeButton = StateInfo[currentState].HighestUnlockedShapeButton
	if shape > highestUnlockedShapeButton:
		StateInfo[currentState].HighestUnlockedShapeButton += 1
		print(highestUnlockedShapeButton)
		for button in UIManager.shapeButtons.get_children():
			if button.shapeSprite == shape:
				button.updateVisibility()




#region Grid
func addShapeToStorage(slot: int, shape: Node2D, storage: Array[Dictionary] = gridStorage) -> void:
	if not shape is Eraser:
		storage.append({"slot": slot, "shape": shape, "shape_type": ShapeType.find_key(shape.shapeSprite)})
	else:
		storage.append({"slot": slot, "shape": shape})


func removeShapeFromStorage(shape: Node2D, storage: Array[Dictionary] = gridStorage) -> void:
	for dict in storage:
		if dict["shape"] == shape:
			storage.erase(dict)
			return


func removeShapeFromStorageSlot(slot: int, storage: Array[Dictionary] = gridStorage) -> void:
	for dict in storage:
		if dict["slot"] == slot:
			storage.erase(dict)
			return


func getShapeInStorageBySlot(slot: int, storage: Array[Dictionary] = gridStorage) -> Node2D:
	for dict in storage:
		if dict["slot"] == slot:
			return dict["shape"]
	return null


func getSlotInStorageByShape(shape: Node2D, storage: Array[Dictionary] = gridStorage):
	for dict in storage:
		if dict["shape"] == shape:
			return dict["slot"]
	return null


func clearStorage(storage: Array[Dictionary] = gridStorage) -> void:
	storage.clear()

func transferBetweenStorages(storageA: Array[Dictionary], storageB: Array[Dictionary]) -> void:
	storageA.append_array(storageB)


func getShapeCount(shape: Shape.ShapeSprite) -> int:
	var count: int = 0
	
	for dict in gridStorage:
		var storedShape = dict["shape"]
		if storedShape.shapeSprite == shape:
			count += 1
		
	return count

#endregion


#region Number Formatting

enum BigNumbers {
	MILLION = 10**6,
	TEN_MILLION = 10**7,
	HUNDRED_MILLION = 10**8,
	BILLION = 10**9,
	TEN_BILLION = 10**10,
	HUNDRED_BILLION = 10**11,
	TRILLION = 10**12,
	TEN_TRILLION = 10**13,
	HUNDRED_TRILLION = 10**14,
	QUADRILLION = 10**15,
	TEN_QUADRILLION = 10**16,
	HUNDRED_QUADRILLION = 10**17,
	QUINTILLION = 10**18
}

var notations: Dictionary = {
	MILLION = {SCIENTIFIC = "e6", ENGINEERING = "e6", ABBREVIATION = "M"},
	TEN_MILLION = {SCIENTIFIC = "e7"},
	HUNDRED_MILLION = {SCIENTIFIC = "e8"},
	BILLION = {SCIENTIFIC = "e9", ENGINEERING = "e9", ABBREVIATION = "B"},
	TEN_BILLION = {SCIENTIFIC = "e10"},
	HUNDRED_BILLION = {SCIENTIFIC = "e11"},
	TRILLION = {SCIENTIFIC = "e12", ENGINEERING = "e12", ABBREVIATION = "T"},
	TEN_TRILLION = {SCIENTIFIC = "e13"},
	HUNDRED_TRILLION = {SCIENTIFIC = "e14"},
	QUADRILLION = {SCIENTIFIC = "e15", ENGINEERING = "e15", ABBREVIATION = "Qd"},
	TEN_QUADRILLION = {SCIENTIFIC = "e16"},
	HUNDRED_QUADRILLION = {SCIENTIFIC = "e17"},
	QUINTILLION = {SCIENTIFIC = "e18", ENGINEERING = "e18", ABBREVIATION = "Qn"}
}

func formatMoney(value: int) -> String:
	if notationStyle == NotationStyle.NONE or value < BigNumbers.MILLION:
		return str(value)
	
	var searchKey: String
	
	for numKey in BigNumbers:
		if notationStyle != NotationStyle.SCIENTIFIC and ("TEN" in numKey or "HUNDRED" in numKey):
			continue
		if value >= BigNumbers[numKey]:
			searchKey = numKey
		else:
			break
	
	var suffix = notations[searchKey][NotationStyle.find_key(notationStyle)] if searchKey else ""
	var newValue = float(value) / BigNumbers[searchKey] if searchKey else value
	
	return ("%.2f" % (floor(newValue / 0.01) * 0.01)) + suffix

#endregion

func saveGame() -> void:
	var saveData = {
		"money": money,
		"currentState": currentState,
		"currentBigShapeType": currentBigShapeType,
		"gridSize": gridSize,
		"interval": interval,
		"synergyUnlocked": synergyUnlocked,
		"synergyMulti": synergyMulti,
		"highestUnlockedShapeButton": StateInfo[currentState].HighestUnlockedShapeButton,
		"gridStorage": gridStorage,
		
		"intervalUpgradeLevel": UpgradeInfo[UpgradeType.Interval].CurrentLevel,
		"intervalUpgradeNextCost": UpgradeInfo[UpgradeType.Interval].NextLevelCost,
		"gridUpgradeLevel": UpgradeInfo[UpgradeType.Grid].CurrentLevel,
		"gridUpgradeNextCost": UpgradeInfo[UpgradeType.Grid].NextLevelCost,
		"synergyUnlockedLevel": UpgradeInfo[UpgradeType.SynergyUnlock].CurrentLevel,
		"synergyUnlockedUNextCost": UpgradeInfo[UpgradeType.SynergyUnlock].NextLevelCost,
		"synergyMultiLevel": UpgradeInfo[UpgradeType.SynergyMulti].CurrentLevel,
		"synergyMultiUpgradeNextCost": UpgradeInfo[UpgradeType.SynergyMulti].NextLevelCost,
		
		"masterVolume": SoundManager.masterVolume,
		"musicVolume": SoundManager.musicVolume,
		"sfxVolume": SoundManager.sfxVolume,
		"notationStyle": notationStyle
	}
	
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	
	if file:
		file.store_string(JSON.stringify(saveData))
		file.close()

func loadSaveFile() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		return
	
	var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	
	if file:
		var saveData = JSON.parse_string(file.get_as_text())
		file.close()
		
		if saveData is Dictionary:
			money = saveData.get("money", START_MONEY)
			currentState = saveData.get("currentState", START_STATE)
			currentBigShapeType = saveData.get("currentBigShapeType", START_BIG_SHAPE)
			gridSize = saveData.get("gridSize", BASE_GRID_SIZE)
			interval = saveData.get("interval", BASE_INTERVAL)
			synergyUnlocked = saveData.get("synergyUnlocked", false)
			synergyMulti = saveData.get("synergyMulti", BASE_SHAPE_SYNERGY_MULTI)
			StateInfo[currentState].HighestUnlockedShapeButton = saveData.get("highestUnlockedShapeButton", currentState)
			gridStorage.assign(saveData.get("gridStorage", []))
			
			var intervalBaseCost = UpgradeInfo[UpgradeType.Interval].BaseCost
			var gridBaseCost = UpgradeInfo[UpgradeType.Grid].BaseCost
			var synergyUnlockBaseCost = UpgradeInfo[UpgradeType.SynergyUnlock].BaseCost
			var synergyMultiBaseCost = UpgradeInfo[UpgradeType.SynergyMulti].BaseCost
			
			UpgradeInfo[UpgradeType.Interval].CurrentLevel = saveData.get("intervalUpgradeLevel", 0)
			UpgradeInfo[UpgradeType.Interval].NextLevelCost = saveData.get("intervalUpgradeNextCost", intervalBaseCost)
			UpgradeInfo[UpgradeType.Grid].CurrentLevel = saveData.get("gridUpgradeLevel", 0)
			UpgradeInfo[UpgradeType.Grid].NextLevelCost = saveData.get("gridUpgradeNextCost", gridBaseCost)
			UpgradeInfo[UpgradeType.SynergyUnlock].CurrentLevel = saveData.get("synergyUnlockedLevel", 0)
			UpgradeInfo[UpgradeType.SynergyUnlock].NextLevelCost = saveData.get("synergyUnlockedUNextCost", synergyUnlockBaseCost)
			UpgradeInfo[UpgradeType.SynergyMulti].CurrentLevel = saveData.get("synergyMultiLevel", 0)
			UpgradeInfo[UpgradeType.SynergyMulti].NextLevelCost = saveData.get("synergyMultiUpgradeNextCost", synergyMultiBaseCost)
			
			SoundManager.masterVolume = saveData.get("masterVolume", 1.0)
			SoundManager.musicVolume = saveData.get("musicVolume", 1.0)
			SoundManager.sfxVolume = saveData.get("sfxVolume", 1.0)
			notationStyle = saveData.get("notationStyle", NotationStyle.ABBREVIATION)

func saveSettings() -> void:
	var settingsData = {
		"masterVolume": SoundManager.masterVolume,
		"musicVolume": SoundManager.musicVolume,
		"sfxVolume": SoundManager.sfxVolume,
		"notationStyle": notationStyle
	}
	
	var file = FileAccess.open(SETTINGS_PATH, FileAccess.WRITE)
	
	if file:
		file.store_string(JSON.stringify(settingsData))
		file.close()

func loadSettingsFile() -> void:
	if not FileAccess.file_exists(SETTINGS_PATH):
		return
	
	var file = FileAccess.open(SETTINGS_PATH, FileAccess.READ)
	
	if file:
		var settingsData = JSON.parse_string(file.get_as_text())
		file.close()
		
		if settingsData is Dictionary:
			SoundManager.masterVolume = settingsData.get("masterVolume", 1.0)
			SoundManager.musicVolume = settingsData.get("musicVolume", 1.0)
			SoundManager.sfxVolume = settingsData.get("sfxVolume", 1.0)
			notationStyle = settingsData.get("notationStyle", NotationStyle.ABBREVIATION)

func resetGame() -> void:
	if FileAccess.file_exists(SAVE_PATH):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(SAVE_PATH))
	
	money = START_MONEY
	currentState = START_STATE
	currentBigShapeType = START_BIG_SHAPE
	gridSize = BASE_GRID_SIZE
	interval = BASE_INTERVAL
	synergyUnlocked = false
	synergyMulti = BASE_SHAPE_SYNERGY_MULTI
	StateInfo[currentState].HighestUnlockedShapeButton = currentState
	gridStorage = []
	
	var intervalBaseCost = UpgradeInfo[UpgradeType.Interval].BaseCost
	var gridBaseCost = UpgradeInfo[UpgradeType.Grid].BaseCost
	var synergyUnlockBaseCost = UpgradeInfo[UpgradeType.SynergyUnlock].BaseCost
	var synergyMultiBaseCost = UpgradeInfo[UpgradeType.SynergyMulti].BaseCost
	
	UpgradeInfo[UpgradeType.Interval].CurrentLevel = 0
	UpgradeInfo[UpgradeType.Interval].NextLevelCost = intervalBaseCost
	UpgradeInfo[UpgradeType.Grid].CurrentLevel = 0
	UpgradeInfo[UpgradeType.Grid].NextLevelCost = gridBaseCost
	UpgradeInfo[UpgradeType.SynergyUnlock].CurrentLevel = 0
	UpgradeInfo[UpgradeType.SynergyUnlock].NextLevelCost = synergyUnlockBaseCost
	UpgradeInfo[UpgradeType.SynergyMulti].CurrentLevel = 0
	UpgradeInfo[UpgradeType.SynergyMulti].NextLevelCost = synergyMultiBaseCost
