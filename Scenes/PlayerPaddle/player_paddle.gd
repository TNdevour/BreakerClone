extends AnimatableBody2D

@export var _paddle_speed: float = 500.0
@export var _can_move: bool = false
@onready var texture_rect: TextureRect = $TextureRect

const LENGTH_PADDING: float = 24.0
const LEFT_INPUT:String = "move_left"
const RIGHT_INPUT:String = "move_right"
var _paddle_half_width: float = 0.0
var _start_position:Vector2 = Vector2.ZERO

func _ready() -> void:
	add_to_group(DataManager.PADDLE_GROUP)
	SignalHub.on_start_game.connect(allow_paddle_movement)
	SignalHub.on_game_over.connect(disable_paddle_movement)
	_paddle_half_width = texture_rect.size.x/2 + LENGTH_PADDING
	_start_position = position

func _physics_process(delta: float) -> void:
	if !_can_move: return
	
	var move_direction: float = Input.get_axis(LEFT_INPUT,RIGHT_INPUT)
	
	var new_x_pos:float = position.x + (move_direction * _paddle_speed * delta)
	new_x_pos = clamp(
		new_x_pos,
		_start_position.x - _paddle_half_width,
		_start_position.x + _paddle_half_width
		)
	position.x = new_x_pos
	##testing paddle bounce
	constant_linear_velocity = Vector2(new_x_pos,0.0)

func allow_paddle_movement()-> void:
	_can_move = true

func disable_paddle_movement(_has_won:bool)-> void:
	_can_move = false
	
