extends Node

@onready var sfx_player: AudioStreamPlayer = $SfxPlayer
@onready var music_player: AudioStreamPlayer = $MusicPlayer

@export var _main_menu_music:AudioStream
@export var _game_music:AudioStream

const BALL_BOUNCE_SOUNDS:MultiSfxHolder = preload("uid://cjasqjftk0f1b")
const SCORE_SFX:AudioStream = preload("uid://7c8h1kamumvg")
const GAMEOVER_SFX:AudioStream = preload("uid://c8w02pfsyld36")
const CLICK_SFX:AudioStream = preload("uid://be8sxs4vws4w2")
const COUNTDOWN_SFX:AudioStream = preload("uid://gv03xuh6pm2p")

const MIN_PITCH:float = 1.0
const MAX_PITCH:float = 1.2

var _ball_bound_sounds:MultiSfxHolder = BALL_BOUNCE_SOUNDS

func _ready() -> void:
	SignalHub.on_ball_bounce.connect(play_ball_bounce_sfx)
	SignalHub.on_ai_scored.connect(play_score_sfx)
	SignalHub.on_player_scored.connect(play_score_sfx)
	SignalHub.on_game_over.connect(play_game_over_sfx)
	SignalHub.on_start_game.connect(play_game_music)
	SignalHub.on_ball_spawned.connect(play_countdown_sfx)
	SignalHub.on_start_round.connect(play_click_sfx)
	SignalHub.on_life_lost.connect(play_score_sfx)
	SignalHub.on_brick_destroyed.connect(play_click_sfx)
	play_game_music()

func play_ball_bounce_sfx()-> void:
	play_sfx(_ball_bound_sounds.get_random_sfx())

func play_score_sfx()-> void:
	play_sfx(SCORE_SFX)

func play_game_over_sfx(_player_won:bool)-> void:
	music_player.stop()
	play_sfx(GAMEOVER_SFX)

func play_click_sfx()-> void:
	play_sfx(CLICK_SFX)

func play_ball_spawn_sfx(_new_ball: Ball)-> void:
	play_sfx(CLICK_SFX)

func play_countdown_sfx(_new_ball: Ball)-> void:
	play_sfx(COUNTDOWN_SFX)

func play_memu_music()-> void:
	music_player.stream = _main_menu_music
	music_player.play()

func play_game_music()-> void:
	music_player.stream = _game_music
	music_player.play()

func play_sfx(new_stream: AudioStream)-> void:
	sfx_player.stream = new_stream
	sfx_player.pitch_scale = randf_range(MIN_PITCH,MAX_PITCH)
	sfx_player.play()
