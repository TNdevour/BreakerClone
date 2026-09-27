extends Node

@onready var brick_grid: BrickGrid = $BrickGrid
@onready var ball_spawn_point: Marker2D = $BallSpawnPoint
@onready var play_timer: Timer = $PlayTimer

@export var ball_scene:PackedScene

const LAUNCH_DELAY:float = 1.5

var _is_game_over:bool = false
var _game_time:float = 0.0

func _ready() -> void:
	connect_signals()
	spawn_new_ball()
	_is_game_over = false
	play_timer.start()
	reset_game_time()

func connect_signals()-> void:
	SignalHub.on_start_round.connect(spawn_new_ball)
	SignalHub.on_game_over.connect(end_the_game)
	SignalHub.on_life_lost.connect(spawn_new_ball)

func spawn_new_ball()-> void:
	if _is_game_over: return
	
	var new_ball:Ball = ball_scene.instantiate()
	new_ball.position = ball_spawn_point.position
	call_deferred(DataManager.ADD_CHILD_FUNC_NAME,new_ball)
	var tween:Tween = create_tween()
	tween.tween_interval(LAUNCH_DELAY)
	tween.tween_callback(new_ball.launch_ball)

func is_player_alive()->bool:
	return ScoreManager._player_lives > 0

func end_the_game(_game_won:bool)-> void:
	SignalHub.emit_on_game_time_captured(_game_time)
	_is_game_over = true
	reset_game_time()

func reset_game_time()-> void:
	_game_time = 0.0

func _process(delta: float) -> void:
	if _is_game_over: return
	
	_game_time += delta
	print("game_time: %d"%[_game_time])
