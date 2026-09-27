extends Node

#region VARIABLES
var _player_score:float = 0.0
var _high_score:float = 0.0
var _default_player_lives:int = 3
var _player_lives:int = 0
var _final_score:float = 0.0

#var _current_level_no:int = 1

const SCORE_SAVE:String = "user://breaker_score_data.dat"
const LEVEL_SAVE: String = "user://breaker_level_data.dat"
const TIMELIMITFORBONUS: float = 180
const LIFEBONUSSCORE:float = 1000.0
const DEFAULTPLAYERSCORE:float = 0.0

var _level_high_scores:Dictionary[int,Dictionary] ={
	1:{"best_score":0,"best_time":9999},
	2:{"best_score":0,"best_time":9999}
}

#endregion

func _ready() -> void:
	connect_signals()
	set_default_score_values()
	print(
		"_high_score: %d \n_player_lives: %d \n_level_high_scores: %s"
		%[_high_score, _player_lives, _level_high_scores]
	)
	#check_final_results(true)

func connect_signals()-> void:
	SignalHub.on_game_over.connect(check_final_results)
	SignalHub.on_life_lost.connect(remove_player_life)
	SignalHub.on_player_scored.connect(increase_player_score)
	SignalHub.on_start_round.connect(reset_values_for_new_round)

func set_default_score_values() -> void:
	_high_score = load_high_score()
	#_level_high_scores = load_level_high_scores()
	_player_lives = _default_player_lives

#region SAVEMANAGEMENT
func load_high_score()-> float:
	var saved_score:float = 0.0
	var save_file:FileAccess = FileAccess.open(SCORE_SAVE,FileAccess.READ)
	if save_file != null:
		saved_score = save_file.get_float()
	return saved_score

func save_high_score(new_high_score:float)-> void:
	var save_file:FileAccess = FileAccess.open(SCORE_SAVE,FileAccess.WRITE)
	if save_file != null:
		print("new_high_score: %d"%[new_high_score])
		save_file.store_float(new_high_score)
		#save_file.store_double()
	else:
		push_error("File not found at: %s"%[SCORE_SAVE])

func load_level_high_scores()-> Dictionary:
	var level_high_scores:Dictionary = _level_high_scores
	var save_file:FileAccess = FileAccess.open(LEVEL_SAVE,FileAccess.READ)
	if save_file != null:
		var json_text:String = save_file.get_as_text()
		save_file.close()
		var parsed_data = JSON.parse_string(json_text)
		if typeof(parsed_data) == TYPE_DICTIONARY:
			return parsed_data
		else:
			push_error("Invalid data type for level data in %s"%[LEVEL_SAVE])
			return level_high_scores
	else:
		return level_high_scores

func save_level_high_scores(new_level_scores:Dictionary)-> void:
	var json_string:String = JSON.stringify(new_level_scores)
	var save_file:FileAccess = FileAccess.open(LEVEL_SAVE,FileAccess.WRITE)
	if save_file != null:
		save_file.store_string(json_string)

#endregion

#region SCOREMANAGEMENT
func is_high_score_beaten()-> bool:
	return _final_score > _high_score

func is_level_high_score_beaten(level_no:int)-> bool:
	return _final_score > _level_high_scores[level_no].best_score

func reset_player_lives()-> void:
	_player_lives = _default_player_lives

func check_final_results(_has_won:bool)-> void:
	_final_score = calculate_final_score()
	if is_high_score_beaten():
		save_high_score(_final_score)
		SignalHub.emit_on_best_score_beaten()
	#if is_level_best_time_beaten(_current_level_no) or is_level_high_score_beaten(_current_level_no):
		#save_level_high_scores(_level_high_scores)

func increase_player_score(score_to_add:float)-> void:
	_player_score = _player_score + score_to_add
	SignalHub.emit_on_score_updated()

func reset_player_score()-> void:
	_player_score = DEFAULTPLAYERSCORE
	SignalHub.emit_on_score_updated()

func calculate_final_score()-> float:
	var time_bonus = clamp(TIMELIMITFORBONUS - TimeManager._game_time, 0, TIMELIMITFORBONUS)
	var final_score:float = _player_score + (_player_lives * LIFEBONUSSCORE) + time_bonus
	print("final_score: %d"%[final_score])
	return final_score

#endregion

#region LIFEMANAGEMENT
func add_player_life()-> void:
	_player_lives += 1
	_player_lives = clamp(_player_lives,0,_default_player_lives)

func remove_player_life()-> void:
	_player_lives -= 1
	_player_lives = clamp(_player_lives,0, _default_player_lives)
	print("_player_lives: %d"%[_player_lives])
	if is_player_dead(): SignalHub.emit_on_game_over(false)

func is_player_dead()-> bool:
	return _player_lives <= 0

func set_new_default_player_lives(new_default_count: int)-> void:
	_default_player_lives = new_default_count

#endregion

#region

func reset_values_for_new_round()-> void:
	reset_player_lives()
	reset_player_score()
	set_default_score_values()
	SignalHub.emit_on_best_scores_updated()
#endregion
