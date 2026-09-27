extends Node

@export var blackHoleSound: AudioStreamPlayer2D
@export var eraserSound: AudioStreamPlayer2D
@export var menuButtonClick: AudioStreamPlayer2D
@export var menuButtonHover: AudioStreamPlayer2D
@export var noMoneySound: AudioStreamPlayer2D
@export var placeShapeSound: AudioStreamPlayer2D
@export var maxUpgradeSound: AudioStreamPlayer2D
@export var trashcanThrowSound: AudioStreamPlayer2D
@export var trashcanDeleteAllSound: AudioStreamPlayer2D
@export var upgradeButtonSound: AudioStreamPlayer2D
@export var rebirthThresholdSound: AudioStreamPlayer2D
@export var rebirthSound: AudioStreamPlayer2D


@onready var musicPlayer: AudioStreamPlayer = $"Music Player"

@export var menuMusic: AudioStream
@export var gameMusic1: AudioStream
@export var gameMusic2: AudioStream
@export var gameMusic3: AudioStream
@export var creditsMusic: AudioStream

var gameMusicTracks: Array[AudioStream] = []

var masterVolume: float = 1.0
var musicVolume: float = 1.0
var sfxVolume: float = 1.0

func _ready() -> void:
	musicPlayer.finished.connect(onGameMusicFinished)
	gameMusicTracks = [gameMusic1, gameMusic2, gameMusic3]
	
	var masterBusIndex = AudioServer.get_bus_index("Master")
	var musicBusIndex = AudioServer.get_bus_index("Music")
	var sfxBusIndex = AudioServer.get_bus_index("SFX")
	AudioServer.set_bus_volume_db(masterBusIndex, linear_to_db(masterVolume))
	AudioServer.set_bus_volume_db(musicBusIndex, linear_to_db(musicVolume))
	AudioServer.set_bus_volume_db(sfxBusIndex, linear_to_db(sfxVolume))

func stopMusic():
	musicPlayer.stop()
	musicPlayer.stream = null

func playMenuMusic():
	musicPlayer.pitch_scale = 1.0
	if musicPlayer.stream == menuMusic:
		return
	print("Playing Menu Music")
	musicPlayer.stream = menuMusic
	musicPlayer.play()

func playGameMusic():
	musicPlayer.pitch_scale = 1.0
	#if musicPlayer.stream == gameMusic or musicPlayer.stream == gameMusic2 or musicPlayer.stream == gameMusic3:
	#	return
	
	playRandomTrack()

func playCreditsMusic():
	musicPlayer.pitch_scale = 1.0
	if musicPlayer.stream == creditsMusic:
		return
	print("Playing Credits Music")
	musicPlayer.stream = creditsMusic
	musicPlayer.play()

func onGameMusicFinished() -> void:
	if musicPlayer.stream == menuMusic:
		musicPlayer.play()
		print("Playing Menu Music")
	
	playRandomTrack()

func playRandomTrack() -> void:
	var randomTrack = gameMusicTracks.pick_random()
	musicPlayer.stream = randomTrack
	musicPlayer.play()


func playBlackHoleSound() -> void:
	blackHoleSound.play()

func playEraserSound() -> void:
	eraserSound.play()

func playMenuButtonClickSound() -> void:
	menuButtonClick.play()

func playMenuButtonHoverSound() -> void:
	menuButtonHover.play()

func playNoMoneySound() -> void:
	noMoneySound.play()

func playPlaceShapeSound() -> void:
	placeShapeSound.play()

func playMaxUpgradeSound() -> void:
	maxUpgradeSound.play()

func playTrashcanThrowSound() -> void:
	trashcanThrowSound.play()

func playTrashcanDeleteAllSound() -> void:
	trashcanDeleteAllSound.play()

func playUpgradeButtonSound() -> void:
	upgradeButtonSound.play()

func playRebirthThresholdSound() -> void:
	rebirthThresholdSound.play()

func playRebirthSound() -> void:
	rebirthSound.play()


func updateSoundVolumeVariables(busName: String, soundValue: float) -> void:
	match busName:
		"Master":
			masterVolume = soundValue
		"Music":
			musicVolume = soundValue
		"SFX":
			sfxVolume = soundValue
