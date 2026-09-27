extends Node

@export var eraserSound: AudioStreamPlayer2D
@export var eraserPickupSound: AudioStreamPlayer2D
@export var menuButtonClick: AudioStreamPlayer2D
@export var menuButtonHover: AudioStreamPlayer2D
@export var noMoneySound: AudioStreamPlayer2D
@export var shapeButtonSound: AudioStreamPlayer2D
@export var shapeSound: AudioStreamPlayer2D
@export var buyShapeSound: AudioStreamPlayer2D
@export var placeGhostSound: AudioStreamPlayer2D
@export var maxUpgradeSound: AudioStreamPlayer2D
@export var trashcanThrowSound: AudioStreamPlayer2D
@export var trashcanDeleteAllSound: AudioStreamPlayer2D
@export var trashcanNothingSound: AudioStreamPlayer2D
@export var upgradeButtonSound: AudioStreamPlayer2D
@export var rebirthThresholdSound: AudioStreamPlayer2D
@export var rebirthSound: AudioStreamPlayer2D

@export var endSequenceStart1: AudioStreamPlayer2D
@export var endSequenceStart2: AudioStreamPlayer2D
@export var endSequenceStart3: AudioStreamPlayer2D
@export var endSequenceMiddle1: AudioStreamPlayer2D
@export var endSequenceMiddle2: AudioStreamPlayer2D
@export var endSequenceMiddle3: AudioStreamPlayer2D
@export var endSequenceEnd: AudioStreamPlayer2D


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



func playEraserSound() -> void:
	eraserSound.play()

func playEraserPickupSound() -> void:
	eraserPickupSound.play()

func playMenuButtonClickSound() -> void:
	menuButtonClick.play()

func playMenuButtonHoverSound() -> void:
	menuButtonHover.play()

func playNoMoneySound() -> void:
	noMoneySound.play()

func playShapeButtonSound() -> void:
	shapeButtonSound.play()

func playShapeSound() -> void:
	shapeSound.play()

func playBuyShapeSound() -> void:
	buyShapeSound.play()

func playPlaceGhostSound() -> void:
	placeGhostSound.play()

func playMaxUpgradeSound() -> void:
	maxUpgradeSound.play()

func playTrashcanThrowSound() -> void:
	trashcanThrowSound.play()

func playTrashcanDeleteAllSound() -> void:
	trashcanDeleteAllSound.play()

func playTrashcanNothingSound() -> void:
	trashcanNothingSound.play()

func playUpgradeButtonSound() -> void:
	upgradeButtonSound.play()

func playRebirthThresholdSound() -> void:
	rebirthThresholdSound.play()

func playRebirthSound() -> void:
	rebirthSound.play()



func playEndSequenceStart1() -> void:
	endSequenceStart1.play()

func playEndSequenceStart2() -> void:
	endSequenceStart2.play()

func playEndSequenceStart3() -> void:
	endSequenceStart3.play()

func playEndSequenceMiddle1() -> void:
	endSequenceMiddle1.play()

func playEndSequenceMiddle2() -> void:
	endSequenceMiddle2.play()

func playEndSequenceMiddle3() -> void:
	endSequenceMiddle3.play()

func playEndSequenceEnd() -> void:
	endSequenceEnd.play()


func updateSoundVolumeVariables(busName: String, soundValue: float) -> void:
	match busName:
		"Master":
			masterVolume = soundValue
		"Music":
			musicVolume = soundValue
		"SFX":
			sfxVolume = soundValue
