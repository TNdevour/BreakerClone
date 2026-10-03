extends Camera2D

@export var decay:float = 0.6
@export var max_displacement:Vector2 = Vector2(30,20)
@export var max_roll = 0.1
@export var target_node:NodePath

@onready var _noise:FastNoiseLite = FastNoiseLite.new()
var noise_y: int = 0
var trauma:float = 0.0
var trauma_power:int = 2
var default_position:Vector2 = Vector2.ZERO
var default_offset:Vector2 = Vector2.ZERO

func _ready() -> void:
	connect_signals()
	randomize()
	set_noise_parameters()
	set_default_position_stats()

func _process(delta: float) -> void:
	if target_node:
		global_position = get_node(target_node).global_position
	#else:
		#track_default_position_stats()
	if trauma:
		print("trauma: %f"%[trauma])
		trauma = max(trauma - decay * delta, 0.0)
		shake()
	else:
		track_default_position_stats()

func add_trauma(amount: float)-> void:
	#print("trauma to add: %f"%[amount])
	trauma = min(amount + trauma, 1.0)
	#print("added trauma: %f"%[trauma])

func shake()-> void:
	noise_y += 1
	var amount:float = pow(trauma, trauma_power)
	rotation = max_roll * amount * _noise.get_noise_2d(_noise.seed, noise_y)
	offset.x = max_displacement.x * amount * _noise.get_noise_2d(_noise.seed*2, noise_y)
	offset.y = max_displacement.y * amount * _noise.get_noise_2d(_noise.seed*3, noise_y)

func shake_cam_by_trauma_amount(trauma_amount: float)-> void:
	print("Shake signal got to the desired func. Trauma amount %f"%[trauma_amount])
	add_trauma(trauma_amount)

func set_default_position_stats()-> void:
	default_position = Vector2(get_viewport_rect().end.x/2, get_viewport_rect().end.y/2)
	default_offset = offset

func track_default_position_stats()->void:
	global_position = default_position
	offset = default_offset

func set_noise_parameters()-> void:
	_noise.noise_type = _noise.TYPE_PERLIN
	_noise.seed = randi()
	_noise.fractal_octaves = 4

func connect_signals()-> void:
	SignalHub.on_invoke_camera_shake.connect(shake_cam_by_trauma_amount)
