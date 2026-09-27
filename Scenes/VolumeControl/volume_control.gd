extends HBoxContainer

@onready var h_slider: HSlider = $HSlider
@onready var label: Label = $Label

@export var volume_label:String = "MUSIC"
@export var audio_bus_name:String = "Music"

var _audio_bus_id:int = 0

func _ready() -> void:
	_audio_bus_id = AudioServer.get_bus_index(audio_bus_name)
	label.text = volume_label

func _on_h_slider_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_linear(_audio_bus_id, value)
