extends Node

var player: AudioStreamPlayer

func _ready():
	add_to_group("music")
	
	# Create the audio player
	player = AudioStreamPlayer.new()
	add_child(player)
	
	# Load and play the track
	player.stream = preload("res://OhGolly!Haha by Dasan.mp3")
	player.volume_db = -10.0 
	player.play()
