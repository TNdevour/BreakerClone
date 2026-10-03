extends Node

@onready var brick_grid: BrickGrid = $BrickGrid
@onready var ball_spawn_point: Marker2D = $BallSpawnPoint

@export var ball_scene:PackedScene

const LAUNCH_DELAY:float = 1.5

var _is_game_over:bool = false

func _ready() -> void:
	connect_signals()
	spawn_new_ball()
	_is_game_over = false

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

func end_the_game(_game_won:bool)-> void:
	_is_game_over = true
