extends Node

signal on_player_scored(points_scored: float)
signal on_ball_spawned(new_ball:Ball)
signal on_start_round
signal on_start_game
signal on_game_over(player_won:bool)
signal on_ball_bounce
signal on_difficulty_set(new_difficulty:String)
signal on_life_lost
signal on_brick_destroyed
signal on_score_updated
signal on_game_time_captured(game_time: float)
signal on_best_time_beaten
signal on_best_score_beaten
signal on_best_scores_updated
signal on_pause_state_toggled(is_game_paused:bool)
signal on_invoke_camera_shake(trauma_amount:float)

func emit_on_player_scored(points_scored: float) -> void:
	on_player_scored.emit(points_scored)

func emit_on_ball_spawned(new_ball:Ball)-> void:
	on_ball_spawned.emit(new_ball)

func emit_on_start_round()-> void:
	on_start_round.emit()

func emit_on_start_game()->void:
	on_start_game.emit()

func emit_on_game_over(player_won:bool)-> void:
	on_game_over.emit(player_won)

func emit_on_ball_bounce()-> void:
	on_ball_bounce.emit()

func emit_on_difficulty_set(new_difficulty:String)-> void:
	on_difficulty_set.emit(new_difficulty)

func emit_on_life_lost()-> void:
	on_life_lost.emit()

func emit_on_brick_destroyed()-> void:
	on_brick_destroyed.emit()

func emit_on_score_updated()-> void:
	on_score_updated.emit()

func emit_on_game_time_captured(game_time: float)-> void:
	on_game_time_captured.emit(game_time)

func emit_on_best_time_beaten()-> void:
	on_best_time_beaten.emit()

func emit_on_best_score_beaten()-> void:
	on_best_score_beaten.emit()

func emit_on_best_scores_updated()-> void:
	on_best_scores_updated.emit()

func emit_on_pause_state_toggled(is_game_paused:bool)-> void:
	on_pause_state_toggled.emit(is_game_paused)

func emit_on_invoke_camera_shake(trauma_amount:float)-> void:
	on_invoke_camera_shake.emit(trauma_amount)
