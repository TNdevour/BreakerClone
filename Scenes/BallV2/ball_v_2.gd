##A characterbody2d based implementation of the ball.
##Created to allow easier control over what the ball's movement than the rigidbody2d implementation.

class_name Ball extends CharacterBody2D

@export var _can_move:bool = false
@export var _speed:float = 500.0

var _horizontal_value:float = 0
var _vertical_value:float = 0
var _launch_direction:Vector2 = Vector2.ZERO

@onready var collision_timer: Timer = $CollisionTimer
@onready var arrow_pivot: Marker2D = $ArrowPivot
@onready var arrow: Polygon2D = $ArrowPivot/Arrow

const SPEED_MULTIPLIER: float = 1.05
const X_DIRECTION_VALUE: float = 1.0
const MAX_Y_VALUE: float = -0.8
const MIN_Y_VALUE: float = -0.5
const AIM_FACTOR: float = 10000.0
const ADDED_VELOCITY_AFTER_BOUNCE:float = 0.5

func _ready() -> void:
	connect_signals()
	set_new_direction()
	aim_ball()

func connect_signals()-> void:
	SignalHub.on_ball_launched.connect(launch_ball)
	SignalHub.on_life_lost.connect(destroy_ball)
	SignalHub.on_game_over.connect(remove_ball_for_end_game)

func aim_ball()-> void:
	arrow_pivot.look_at(_launch_direction * AIM_FACTOR)
	arrow_pivot.show()

func launch_ball()-> void:
	_can_move = true
	arrow_pivot.hide()
	arrow.hide()
	print("_launch_direction: %s"%[_launch_direction])

func set_new_direction()-> void:
	_horizontal_value =  [-X_DIRECTION_VALUE,X_DIRECTION_VALUE].pick_random()
	_vertical_value =  [MIN_Y_VALUE,MAX_Y_VALUE].pick_random()
	_launch_direction = Vector2(_horizontal_value, _vertical_value).normalized()

func _physics_process(delta: float) -> void:
	if !_can_move: return
	
	var collision:= move_and_collide(_launch_direction * delta * _speed)
	if collision and collision_timer.is_stopped():
		SignalHub.emit_on_ball_bounce()
		collision_timer.start()
		_launch_direction = _launch_direction.bounce(collision.get_normal())
		if collision.get_collider().is_in_group(DataManager.CEILING_GROUP):
			_speed *= SPEED_MULTIPLIER
		if collision.get_collider().is_in_group(DataManager.BRICK_GROUP):
			print("collided with: %s"%[collision.get_collider()])
		if collision.get_collider().is_in_group(DataManager.PADDLE_GROUP):
			velocity.x += collision.get_collider_velocity().x * ADDED_VELOCITY_AFTER_BOUNCE
			velocity = velocity.normalized() * _speed

func destroy_ball()->void:
	print("Ball: Ball destroyed")
	set_deferred(DataManager.QUEUE_FREE_FUNC_NAME, self)

func remove_ball_for_end_game(_is_game_won:bool)-> void:
	destroy_ball()
