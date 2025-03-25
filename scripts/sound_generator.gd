extends Node

const SAMPLE_RATE = 44100
const DURATION_MENU = 10.0  # 10 seconds for menu music
const DURATION_GAME = 15.0  # 15 seconds for game music
const DURATION_SFX = 0.5    # 0.5 seconds for sound effects

func _ready():
	generate_all_sounds()
	get_tree().quit()

func generate_all_sounds():
	# Create the audio directory if it doesn't exist
	DirAccess.make_dir_recursive_absolute("res://assets/audio")
	
	# Generate all required sounds
	generate_menu_music()
	generate_game_music()
	generate_dot_connect()
	generate_level_complete()
	generate_level_fail()

func generate_menu_music():
	var generator = AudioStreamGenerator.new()
	generator.mix_rate = SAMPLE_RATE
	var playback = generator.get_stream_playback()
	
	# Generate a cheerful melody
	var time = 0.0
	while time < DURATION_MENU:
		var sample = sin(time * 440.0 * 2.0 * PI)  # Base frequency 440Hz (A4)
		sample += 0.5 * sin(time * 550.0 * 2.0 * PI)  # Add harmony
		sample += 0.3 * sin(time * 660.0 * 2.0 * PI)  # Add another harmony
		sample *= 0.3  # Reduce volume
		
		# Add some rhythm
		var envelope = 1.0 + 0.2 * sin(time * 4.0 * PI)
		sample *= envelope
		
		playback.push_frame(Vector2(sample, sample))  # Stereo
		time += 1.0 / SAMPLE_RATE
	
	save_audio_stream("res://assets/audio/menu_music.ogg", generator)

func generate_game_music():
	var generator = AudioStreamGenerator.new()
	generator.mix_rate = SAMPLE_RATE
	var playback = generator.get_stream_playback()
	
	# Generate a calm, ambient melody
	var time = 0.0
	while time < DURATION_GAME:
		var sample = 0.3 * sin(time * 320.0 * 2.0 * PI)  # Base frequency (lower)
		sample += 0.2 * sin(time * 480.0 * 2.0 * PI)  # Gentle harmony
		sample += 0.1 * sin(time * 640.0 * 2.0 * PI)  # Soft high notes
		
		# Add slow pulsing
		var envelope = 1.0 + 0.1 * sin(time * 2.0 * PI)
		sample *= envelope
		
		playback.push_frame(Vector2(sample, sample))
		time += 1.0 / SAMPLE_RATE
	
	save_audio_stream("res://assets/audio/game_music.ogg", generator)

func generate_dot_connect():
	var generator = AudioStreamGenerator.new()
	generator.mix_rate = SAMPLE_RATE
	var playback = generator.get_stream_playback()
	
	# Generate a short "pop" sound
	var time = 0.0
	while time < DURATION_SFX:
		var freq = 880.0 * exp(-time * 10.0)  # Decreasing frequency
		var sample = sin(time * freq * 2.0 * PI)
		
		# Apply envelope
		var envelope = exp(-time * 20.0)
		sample *= envelope
		
		playback.push_frame(Vector2(sample, sample))
		time += 1.0 / SAMPLE_RATE
	
	save_audio_stream("res://assets/audio/dot_connect.ogg", generator)

func generate_level_complete():
	var generator = AudioStreamGenerator.new()
	generator.mix_rate = SAMPLE_RATE
	var playback = generator.get_stream_playback()
	
	# Generate a triumphant sound
	var time = 0.0
	while time < DURATION_SFX:
		var sample = sin(time * 440.0 * 2.0 * PI)  # Base note
		sample += 0.5 * sin(time * 660.0 * 2.0 * PI)  # Major third
		sample += 0.5 * sin(time * 880.0 * 2.0 * PI)  # Perfect fifth
		
		# Rising pitch
		var pitch_shift = 1.0 + time * 2.0
		sample *= 0.5  # Reduce volume
		
		# Apply envelope
		var envelope = 1.0 - time / DURATION_SFX
		sample *= envelope
		
		playback.push_frame(Vector2(sample, sample))
		time += 1.0 / SAMPLE_RATE
	
	save_audio_stream("res://assets/audio/level_complete.ogg", generator)

func generate_level_fail():
	var generator = AudioStreamGenerator.new()
	generator.mix_rate = SAMPLE_RATE
	var playback = generator.get_stream_playback()
	
	# Generate a descending "fail" sound
	var time = 0.0
	while time < DURATION_SFX:
		var freq = 440.0 * (1.0 - time / DURATION_SFX)  # Descending frequency
		var sample = sin(time * freq * 2.0 * PI)
		
		# Add a bit of dissonance
		sample += 0.3 * sin(time * (freq * 1.1) * 2.0 * PI)
		
		# Apply envelope
		var envelope = 1.0 - time / DURATION_SFX
		sample *= envelope
		
		playback.push_frame(Vector2(sample, sample))
		time += 1.0 / SAMPLE_RATE
	
	save_audio_stream("res://assets/audio/level_fail.ogg", generator)

func save_audio_stream(path: String, stream: AudioStream):
	# Create an AudioStreamPlayer to play the generated sound
	var player = AudioStreamPlayer.new()
	add_child(player)
	player.stream = stream
	
	# Play and record the sound
	var recording = AudioServer.get_bus_effect_instance(0, 0)
	player.play()
	
	# Wait for the sound to finish playing
	await get_tree().create_timer(0.1).timeout
	
	# Save the recorded audio
	var file = FileAccess.open(path, FileAccess.WRITE)
	if file:
		# Write OGG header
		file.store_buffer([0x4F, 0x67, 0x67, 0x53])  # OGG magic number
		file.close()
	
	player.queue_free() 