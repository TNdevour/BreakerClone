class_name BrickGrid extends Node2D

var _brick_scene:PackedScene = preload("uid://pqog2t3at2aq")
# grid display variables
@export var grid_columns:int = 7:
	set(value):
		grid_columns = value
@export var grid_rows:int = 5:
	set(value):
		grid_rows = value
var _grid_left_pad: float = 370.0
var _grid_top_pad:float = 20.0
var _grid_ver_separation:float = 5.0
var _grid_hor_separation:float = 5.0
var _total_bricks:int = 0

#region CORE
func _ready() -> void:
	connect_signals()
	populate_grid()
	set_total_bricks()
	print("_total_bricks: %d"%[_total_bricks])

func connect_signals()-> void:
	SignalHub.on_brick_destroyed.connect(remove_a_brick)

func _to_string() -> String:
	return "grid: [%d x %d] "%[grid_columns,grid_rows]

#endregion

#region GRIDMANAGEMENT
func populate_grid()-> void:
	for col:int in grid_columns:
		for row:int in grid_rows:
			var brick:Brick = _brick_scene.instantiate()
			add_child(brick)
			brick.position = Vector2(
				_grid_left_pad + col * (brick.color_rect.size.x + _grid_hor_separation), 
				_grid_top_pad + row * (brick.color_rect.size.y + _grid_ver_separation)
				)
func clear_grid()-> void:
	for brick in get_tree().get_nodes_in_group(DataManager.BRICK_GROUP):
		brick.queue_free()

#endregion

#region BRICKMANAGEMENT
func reset_bricks()-> void:
	_total_bricks = 0

func remove_a_brick()->void:
	_total_bricks -= 1
	#print("_total_bricks: %d"%[_total_bricks])
	if are_all_bricks_destroyed():
		SignalHub.emit_on_game_over(true)

func are_all_bricks_destroyed()-> bool:
	return _total_bricks <= 0

func set_total_bricks()-> void:
	var brick_array:Array = get_tree().get_nodes_in_group(DataManager.BRICK_GROUP)
	_total_bricks = brick_array.size()

#endregion
