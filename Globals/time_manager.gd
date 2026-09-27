extends Node

var _game_time:float = 0.0
var _best_time:float = 9999.0
var _is_game_over:bool = true
var _is_game_paused:bool = false

const TIME_SAVE:String = "user://breaker_time_data.dat"

func connect_signals()-> void:
	SignalHub.on_start_round.connect(start_timer)
	SignalHub.on_pause_state_toggled.connect(pause_timer)
	SignalHub.on_game_over.connect(stop_timer)

func _ready()-> void:
	connect_signals()
	start_timer()

func reset_game_time()-> void:
	_game_time = 0.0

func start_timer()-> void:
	reset_game_time()
	update_best_time(load_best_time())
	_is_game_over = false

func stop_timer(_game_won:bool)-> void:
	_is_game_over = true
	if _game_won:
		if is_best_time_beaten():
			save_best_time(_game_time)
			update_best_time(_game_time)
			SignalHub.emit_on_best_time_beaten()

func pause_timer(pause_state: bool)-> void:
	_is_game_paused = pause_state

func save_best_time(new_best_time:float)-> void:
	var save_file:FileAccess = FileAccess.open(TIME_SAVE, FileAccess.WRITE)
	if save_file!= null:
		save_file.store_float(new_best_time)
	else:
		push_error("File not found at: %s "%[TIME_SAVE])

func load_best_time()-> float:
	var best_time:float = 9999
	var save_file:FileAccess = FileAccess.open(TIME_SAVE,FileAccess.READ)
	if save_file != null:
		best_time = save_file.get_float()
	return best_time

func is_best_time_beaten()-> bool:
	return _game_time < _best_time

func set_default_score_values() -> void:
	_best_time = load_best_time()

func update_best_time(new_best_time:float)-> void:
	_best_time = new_best_time

func _process(delta: float) -> void:
	if _is_game_over or _is_game_paused: return
	
	_game_time += delta
	print("game_time: %d"%[_game_time])
