extends HBoxContainer

@onready var h_slider: HSlider = $HSlider
@onready var label: Label = $Label

@export var volume_label:String = "MUSIC"
@export var audio_bus_name:String = "Music"

func _ready() -> void:
	label.text = volume_label
	h_slider.value = SoundManager.get_channel_volume_by_audiobus(audio_bus_name)

func _on_h_slider_value_changed(value: float) -> void:
	SoundManager.set_volume_for_bus(audio_bus_name,value)
