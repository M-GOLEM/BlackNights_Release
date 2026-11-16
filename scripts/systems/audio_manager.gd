extends Node

const MUSIC_DIR := "res://assets/audio/music/"
const SFX_DIR := "res://assets/audio/sfx/"
const AMBIENCE_DIR := "res://assets/audio/ambience/"

var _music: AudioStreamPlayer
var _music_tween: Tween
var _ambience: AudioStreamPlayer
var _ambience_tween: Tween
var _sfx_pool: Array[AudioStreamPlayer] = []


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_ensure_bus("Music")
	_ensure_bus("SFX")
	_music = AudioStreamPlayer.new()
	_music.bus = "Music"
	add_child(_music)
	_ambience = AudioStreamPlayer.new()
	_ambience.bus = "Music"
	_ambience.volume_db = -11.0
	add_child(_ambience)
	for i in 6:
		var player := AudioStreamPlayer.new()
		player.bus = "SFX"
		add_child(player)
		_sfx_pool.append(player)
	SaveSystem.settings_changed.connect(apply_volumes)
	apply_volumes()


func apply_volumes() -> void:
	_set_bus_volume("Master", SaveSystem.volume("Master"))
	_set_bus_volume("Music", SaveSystem.volume("Music"))
	_set_bus_volume("SFX", SaveSystem.volume("SFX"))


func play_chapter_music(chapter: int) -> void:
	play_music("%sch%02d_ambient.ogg" % [MUSIC_DIR, chapter])
	if chapter >= 1 and chapter <= 7:
		play_ambience("%samb_ch%02d.ogg" % [AMBIENCE_DIR, chapter])


func play_menu_music() -> void:
	play_music(MUSIC_DIR + "menu_ambient.ogg")
	play_ambience(AMBIENCE_DIR + "amb_menu.ogg")


func play_ambience(path: String, fade_seconds := 2.0) -> void:
	var resolved := _resolve(path)
	if resolved == "":
		return
	if _ambience.stream != null and _ambience.stream.resource_path == resolved:
		return
	var stream: AudioStream = load(resolved)
	if _ambience_tween != null:
		_ambience_tween.kill()
	_ambience_tween = create_tween()
	if _ambience.playing:
		_ambience_tween.tween_property(_ambience, "volume_db", -40.0, fade_seconds * 0.6)
		_ambience_tween.tween_callback(_start_loop.bind(_ambience, stream))
	else:
		_start_loop(_ambience, stream)
	_ambience_tween.tween_property(_ambience, "volume_db", -11.0, fade_seconds * 0.4)


func play_music(path: String, fade_seconds := 1.5) -> void:
	var resolved := _resolve(path)
	if resolved == "":
		return
	if _music.stream != null and _music.stream.resource_path == resolved:
		return
	var stream: AudioStream = load(resolved)
	if _music_tween != null:
		_music_tween.kill()
	_music_tween = create_tween()
	if _music.playing:
		_music_tween.tween_property(_music, "volume_db", -40.0, fade_seconds * 0.5)
		_music_tween.tween_callback(_start_loop.bind(_music, stream))
	else:
		_start_loop(_music, stream)
	_music_tween.tween_property(_music, "volume_db", 0.0, fade_seconds * 0.5)


func stop_music(fade_seconds := 1.5) -> void:
	if not _music.playing:
		return
	if _music_tween != null:
		_music_tween.kill()
	_music_tween = create_tween()
	_music_tween.tween_property(_music, "volume_db", -40.0, fade_seconds)
	_music_tween.tween_callback(_music.stop)


func play_sfx(sfx_name: String, volume_db := 0.0, pitch := 1.0) -> void:
	var resolved := _resolve(SFX_DIR + sfx_name + ".ogg")
	if resolved == "":
		return
	var player := _get_free_sfx_player()
	player.stream = load(resolved)
	player.volume_db = volume_db
	player.pitch_scale = clampf(pitch, 0.5, 2.0)
	player.play()


func _resolve(path: String) -> String:
	if ResourceLoader.exists(path):
		return path
	var wav := path.get_basename() + ".wav"
	if ResourceLoader.exists(wav):
		return wav
	return ""


func _start_loop(player: AudioStreamPlayer, stream: AudioStream) -> void:
	if stream is AudioStreamWAV:
		var wav := stream as AudioStreamWAV
		wav.loop_mode = AudioStreamWAV.LOOP_FORWARD
		wav.loop_begin = 0
		wav.loop_end = int(wav.get_length() * wav.mix_rate)
	player.stream = stream
	player.volume_db = -40.0
	player.play()


func _get_free_sfx_player() -> AudioStreamPlayer:
	for player in _sfx_pool:
		if not player.playing:
			return player
	return _sfx_pool[0]


func _ensure_bus(bus_name: String) -> void:
	if AudioServer.get_bus_index(bus_name) != -1:
		return
	var index := AudioServer.bus_count
	AudioServer.add_bus(index)
	AudioServer.set_bus_name(index, bus_name)
	AudioServer.set_bus_send(index, "Master")


func _set_bus_volume(bus_name: String, linear: float) -> void:
	var index := AudioServer.get_bus_index(bus_name)
	if index == -1:
		return
	AudioServer.set_bus_volume_db(index, linear_to_db(maxf(linear, 0.0001)))
	AudioServer.set_bus_mute(index, linear <= 0.001)
