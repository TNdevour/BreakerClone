extends Control

@onready var lives_grid: GridContainer = $HB/VBLeft/VB/LivesGrid
@onready var best_time_value: Label = $HB/VBRight/BestTimeValue
@onready var high_score_label: Label = $HB/VBRight/HighScoreLabel
@onready var game_score_value: Label = $HB/VBRight/GameScoreValue
@onready var options_widget: Control = $OptionsWidget
@onready var game_over_widget: Control = $GameOverWidget
@onready var final_verdict_label: Label = $GameOverWidget/HB2/VB/FinalVerdictLabel
@onready var final_score_label: Label = $GameOverWidget/HB2/VB/FinalScoreLabel
@onready var final_time_label: Label = $GameOverWidget/HB2/VB/FinalTimeLabel
@onready var menu_label: Label = $GameOverWidget/HB2/VB/MenuLabel
@onready var restart_label: Label = $GameOverWidget/HB2/VB/RestartLabel
@onready var new_best_time_label: Label = $GameOverWidget/HB2/VB/NewBestTimeLabel
@onready var new_best_score_label: Label = $GameOverWidget/HB2/VB/NewBestScoreLabel


const HEART_SPHERE = preload("uid://cjv15ujmc3r6g")
enum GameState{READY, PLAYING, PAUSED, GAMEOVER}
var _game_state:GameState = GameState.READY

func _ready() -> void:
	connect_signals()
	set_high_score_values()
	update_lives_display()
	update_score_display()
	hide_special_ui_widgets()
	hide_game_over_ui_elements()
	_game_state = GameState.PLAYING
	announce_game_state()
	

func connect_signals()-> void:
	SignalHub.on_score_updated.connect(update_score_display)
	SignalHub.on_life_lost.connect(reduce_life_count_in_display)
	SignalHub.on_game_over.connect(display_game_over_widget)
	SignalHub.on_best_time_beaten.connect(show_best_time_beaten_label)
	SignalHub.on_best_score_beaten.connect(show_best_score_beaten_label)
	SignalHub.on_best_scores_updated.connect(set_high_score_values)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		toggle_pause()
	if (event.is_action_pressed("pause") or event.is_action_pressed("quit")) and _game_state == GameState.GAMEOVER:
		SignalHub.emit_on_start_round()
		get_tree().reload_current_scene()

func toggle_pause() -> void:
	if get_tree().paused == true and _game_state == GameState.PAUSED:
		print("unpaused")
		get_tree().paused = false
		_game_state = GameState.PLAYING
		options_widget.hide()
		SignalHub.emit_on_pause_state_toggled(false)
		announce_game_state()
	elif _game_state == GameState.PLAYING:
		print("paused")
		get_tree().paused = true
		_game_state = GameState.PAUSED
		options_widget.show()
		SignalHub.emit_on_pause_state_toggled(true)
		announce_game_state()

func update_score_display()-> void:
	game_score_value.text = "%d"%[ScoreManager._player_score]

func set_high_score_values()-> void:
	best_time_value.text = "%d"%[TimeManager._best_time]
	high_score_label.text = "%d"%[ScoreManager._high_score]

func display_lifegrid_contents()-> void:
	for node in lives_grid.get_children():
		print("node: %s"%[node.to_string()])

func update_lives_display()-> void:
	for life_heart in ScoreManager._player_lives:
		var heart_sphere:HeartSphere = HEART_SPHERE.instantiate()
		lives_grid.add_child(heart_sphere)

func clear_lives_display()-> void:
	for node in lives_grid.get_children():
		node.queue_free()

func reduce_life_count_in_display()-> void:
	var heart_spheres:Array[Node] = lives_grid.get_children()
	var latest_heart:Node = heart_spheres.back()
	if latest_heart != null:
		latest_heart.queue_free()

func announce_game_state()-> void:
	print("game_state: %s"% [GameState.find_key(_game_state)])

func display_game_over_widget(is_game_won: bool)-> void:
	_game_state = GameState.GAMEOVER
	game_over_widget.show()
	await get_tree().create_timer(1.0).timeout
	announce_game_state()
	if is_game_won:
		show_final_verdict("You Won!")
		show_final_score()
		show_final_time()
		show_restart_and_menu_labels()
		print("Game won")
	else:
		show_final_verdict("You Lost...")
		show_final_score()
		show_final_time()
		show_restart_and_menu_labels()
		print("Game lost")

func show_final_score()-> void:
	final_score_label.text = "Final Score: %d"%[ScoreManager._final_score]
	final_score_label.show()

func show_final_time()-> void:
	final_time_label.text = "Time: %d seconds"%[TimeManager._game_time]
	final_time_label.show()

func hide_game_over_ui_elements()-> void:
	final_score_label.hide()
	final_verdict_label.hide()
	final_time_label.hide()
	restart_label.hide()
	menu_label.hide()
	new_best_time_label.hide()
	new_best_score_label.hide()

func show_restart_and_menu_labels()-> void:
	restart_label.show()
	#menu_label.show()

func hide_special_ui_widgets()-> void:
	options_widget.hide()
	game_over_widget.hide()

func show_final_verdict(verdict_message:String)-> void:
	final_verdict_label.text = verdict_message
	final_verdict_label.show()

func show_best_time_beaten_label()-> void:
	print("High Score Beaten!!!")
	new_best_time_label.show()

func show_best_score_beaten_label()-> void:
	new_best_score_label.show()
