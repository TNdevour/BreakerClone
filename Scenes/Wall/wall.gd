extends StaticBody2D

@export var _wall_group: String = "walls"

func _ready() -> void:
	add_to_group(_wall_group)	
