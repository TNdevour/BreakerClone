class_name HeartSphere extends Control

@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _ready()-> void:
	SignalHub.on_life_lost.connect(play_flash_anim)
	pass

func play_flash_anim()-> void:
	animation_player.play("flash_white")
