class_name MultiSfxHolder extends Resource

@export var sfx_selection:Array[AudioStream]

func get_random_sfx()-> AudioStream:
	if !sfx_selection.is_empty():
		return sfx_selection.pick_random()
	else:
		print_debug("sfx_selection array is empty. assign some audio files in the inspector")
		return
