extends Node

@onready var sfx_player: AudioStreamPlayer = $SfxPlayer
@onready var music_player: AudioStreamPlayer = $MusicPlayer
@onready var sfx_players: Node = $SFXPlayers

#@export var _main_menu_music:AudioStream
#@export var _game_music:AudioStream

const BALL_BOUNCE_SOUNDS:MultiSfxHolder = preload("uid://cjasqjftk0f1b")
const GAME_BG_TRACKS = preload("uid://cikf8ym0hbrqs")

const SCORE_SFX:AudioStream = preload("uid://7c8h1kamumvg")
const GAMEOVER_SFX:AudioStream = preload("uid://c8w02pfsyld36")
const CLICK_SFX:AudioStream = preload("uid://be8sxs4vws4w2")
const COUNTDOWN_SFX:AudioStream = preload("uid://gv03xuh6pm2p")
const HIGHSCORE_SFX:AudioStream = preload("uid://t40yxorqexnf")
const LIFELOST_SFX:AudioStream = preload("uid://dew58ubegwpk")

const MUSICVOLUMESAVEFILE:String = "user://musiclevel.dat"
const SFXVOLUMESAVEFILE:String = "user://sfxlevel.dat"
const MIN_PITCH:float = 1.0
const MAX_PITCH:float = 1.2
const MASTERBUSNAME:String = "Master"
const SFXBUSNAME:String = "Sfx"
const MUSICBUSNAME:String = "Music"
const DEFAULTVOLUMELEVEL:float = 0.5

var _ball_bound_sounds:MultiSfxHolder = BALL_BOUNCE_SOUNDS
var _game_bg_tracks:MultiSfxHolder = GAME_BG_TRACKS
var _sfx_players_array:Array[AudioStreamPlayer] =[]
var _playing_bg_music_id:int = 0

#region CORE
func _ready() -> void:
	connect_signals()
	populate_sfx_players_array()
	set_volume_for_bus(MUSICBUSNAME, load_volume_level_from_file(MUSICVOLUMESAVEFILE))
	set_volume_for_bus(SFXBUSNAME, load_volume_level_from_file(SFXVOLUMESAVEFILE))
	play_game_music()

func connect_signals()-> void:
	SignalHub.on_ball_bounce.connect(play_ball_bounce_sfx)
	SignalHub.on_player_scored.connect(play_score_sfx)
	SignalHub.on_game_over.connect(play_game_over_sfx)
	SignalHub.on_start_game.connect(play_game_music)
	SignalHub.on_ball_spawned.connect(play_countdown_sfx)
	SignalHub.on_start_round.connect(play_game_music)
	SignalHub.on_life_lost.connect(play_defeat_sfx)
	SignalHub.on_brick_destroyed.connect(play_brick_break_sfx)
	SignalHub.on_best_score_beaten.connect(play_highscore_sfx)
	SignalHub.on_best_time_beaten.connect(play_highscore_sfx)
#endregion

#region PLAY SOUNDS
func play_ball_bounce_sfx()-> void:
	play_sfx(_ball_bound_sounds.get_random_sfx())

func play_score_sfx(_points_scored:float)-> void:
	play_sfx(SCORE_SFX)

func play_game_over_sfx(_player_won:bool)-> void:
	music_player.stop()
	play_sfx(GAMEOVER_SFX)

func play_defeat_sfx()-> void:
	play_sfx(LIFELOST_SFX)

func play_click_sfx()-> void:
	play_sfx(CLICK_SFX)

func play_brick_break_sfx()-> void:
	play_sfx(CLICK_SFX)

func play_ball_spawn_sfx(_new_ball: Ball)-> void:
	play_sfx(CLICK_SFX)

func play_countdown_sfx(_new_ball: Ball)-> void:
	play_sfx(COUNTDOWN_SFX)

func play_highscore_sfx()-> void:
	play_sfx(HIGHSCORE_SFX)

func play_memu_music()-> void:
	music_player.stream = _game_bg_tracks.get_random_sfx()
	music_player.play()

func play_game_music()-> void:
	var random_bg_track:AudioStream = _game_bg_tracks.get_random_track_except_id(_playing_bg_music_id)
	music_player.stream = random_bg_track
	_playing_bg_music_id = _game_bg_tracks.get_track_index(random_bg_track)
	music_player.play()

func play_sfx(new_stream: AudioStream)-> void:
	var free_sfx_player = get_free_sfx_player()
	free_sfx_player.stream = new_stream
	free_sfx_player.pitch_scale = randf_range(MIN_PITCH,MAX_PITCH)
	free_sfx_player.play()
	#print("Active Player: %s"%[free_sfx_player.name])
#endregion

#region VOLUME CONTROL
##Set new volume level for the provided audiobus name.[br]
##If no matching name is found in the preset match list, the master bus will be set instead.
func set_volume_for_bus(audio_bus_name:String, new_volume: float)-> void:
	var audio_bus_id = AudioServer.get_bus_index(audio_bus_name)
	AudioServer.set_bus_volume_linear(audio_bus_id, new_volume)
	match audio_bus_name:
		SFXBUSNAME:
			play_click_sfx()
			save_sfx_volume_level(new_volume)
		MUSICBUSNAME:
			save_music_volume_level(new_volume)
		_:
			save_master_volume_level(new_volume)

func save_master_volume_level(new_volume_level:float)-> void:
	var save_file:FileAccess = FileAccess.open(MASTERBUSNAME,FileAccess.WRITE)
	save_file.store_float(new_volume_level)

func save_music_volume_level(new_volume_level:float)-> void:
	var save_file:FileAccess = FileAccess.open(MUSICVOLUMESAVEFILE,FileAccess.WRITE)
	save_file.store_float(new_volume_level)

func save_sfx_volume_level(new_volume_level:float)-> void:
	var save_file:FileAccess = FileAccess.open(SFXVOLUMESAVEFILE,FileAccess.WRITE)
	save_file.store_float(new_volume_level)

func load_volume_level_from_file(volume_file_name:String)-> float:
	var save_file:FileAccess = FileAccess.open(volume_file_name, FileAccess.READ)
	if save_file != null:
		return save_file.get_float()
	else:
		return DEFAULTVOLUMELEVEL

func get_channel_volume_by_audiobus(audio_bus_name:String)-> float:
	var audio_index:int = AudioServer.get_bus_index(audio_bus_name)
	var audio_volume = AudioServer.get_bus_volume_linear(audio_index)
	return audio_volume

#endregion

##Using multiple AudioStreamPlayers to prevent SFX being cut off during fast actions.[br]
##This should return the next player that is not busy. [br]If all are busy, the default player will be overwritten.
func get_free_sfx_player() -> AudioStreamPlayer:
	if _sfx_players_array.is_empty():
		push_error("_sfx_players_array is empty. Please check and add some audio players to the sfx_players node group ")
		return
	
	for current_sfx_player:AudioStreamPlayer in _sfx_players_array:
		if current_sfx_player != null and !current_sfx_player.playing:
			return current_sfx_player
	return sfx_player

func populate_sfx_players_array() -> void:
	for current_sfx_player:AudioStreamPlayer in sfx_players.get_children():
		_sfx_players_array.append(current_sfx_player)
