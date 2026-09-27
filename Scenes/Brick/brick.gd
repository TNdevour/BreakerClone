class_name Brick extends StaticBody2D

@export var _hit_points:int = 1
@onready var color_rect: ColorRect = $ColorRect
@onready var hit_box: Area2D = $HitBox

var _brick_score_value:float = 20.0

func _ready() -> void:
	add_to_group(DataManager.BRICK_GROUP)

func _on_hit_box_body_entered(body: Node2D) -> void:
	if body is Ball:
		#print("Brick Hit!")
		take_damage()

func take_damage()-> void:
	_hit_points -= 1
	if is_destroyed():
		destroy_brick()

func is_destroyed() -> bool:
	return _hit_points <= 0

func destroy_brick()-> void:
	#print("Brick destroyed!")
	SignalHub.emit_on_brick_destroyed()
	SignalHub.emit_on_player_scored(_brick_score_value)
	queue_free()
	
	
