extends Node3D

@export var background_music: AudioStreamPlayer
@export var rune_music: AudioStreamPlayer
@export var pickup_jingle: AudioStreamPlayer
@export var player: CharacterBody3D

@onready var muted := -80

var current_music = "regular"

func _ready() -> void:
	rune_off()

func rune_on() -> void:
	background_music.set_volume_db(muted)
	rune_music.set_volume_db(PlayerVariables.music_volume)
	current_music = "rune"
	
func rune_off() -> void:
	background_music.set_volume_db(PlayerVariables.music_volume)
	rune_music.set_volume_db(muted)
	current_music = "regular"

func play_jingle() -> void:
	background_music.set_volume_db(muted)
	rune_music.set_volume_db(muted)
	pickup_jingle.play()
	
func stop_jingle() -> void:
	pickup_jingle.stop()
	if current_music == "rune":
		rune_on()
	else:
		rune_off()
