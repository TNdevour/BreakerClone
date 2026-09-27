extends Node

@onready var ball_v_2: Ball = $BallV2
@onready var launch_timer: Timer = $LaunchTimer
@onready var brick_grid: BrickGrid = $BrickGrid

func _ready() -> void:
	launch_timer.start()
	brick_grid.populate_grid()
	print("%s"%[brick_grid.to_string()])

func _on_launch_timer_timeout() -> void:
	ball_v_2.launch_ball()

			
