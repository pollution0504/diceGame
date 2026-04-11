extends Node

func play_sound(stream: AudioStream, volume_db: float = 0.0, pitch: float = 1.0, bus: String = "Master"):
	var player = AudioStreamPlayer.new()
	add_child(player)
	player.stream = stream
	player.volume_db = volume_db
	player.pitch_scale = pitch
	player.bus = bus
	player.play()
	player.finished.connect(player.queue_free)
