extends Marker2D

func _ready() -> void:
	global_position = Vector2(get_viewport_rect().end.x/2, get_viewport_rect().end.y/2)
