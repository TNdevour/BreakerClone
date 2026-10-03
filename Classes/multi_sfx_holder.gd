class_name MultiSfxHolder extends Resource

@export var sfx_selection:Array[AudioStream]

func get_random_sfx()-> AudioStream:
	if !sfx_selection.is_empty():
		return sfx_selection.pick_random()
	else:
		print_debug("sfx_selection array is empty. assign some audio files in the inspector")
		return

##This returns a random AudioStream from a preset array, excluding a specific member of the group[br]
##The ID to be excluded is passed along as the exempted_id[br]
##Initial use was to avoid repeatedly fetching the same track that's already playing
func get_random_track_except_id(exempted_id:int)-> AudioStream:
	if !sfx_selection.is_empty():
		var chosen_track:AudioStream = sfx_selection.pick_random()
		if exempted_id == get_track_index(chosen_track):
			var new_id: int = exempted_id + 1
			if new_id >= sfx_selection.size():
				new_id = 0
			chosen_track = sfx_selection.get(new_id) 
		return chosen_track
	else:
		print_debug("sfx_selection array is empty. assign some audio files in the inspector")
		return
	
func get_track_index(audio_track:AudioStream) -> int:
	if  sfx_selection.has(audio_track):
		return sfx_selection.find(audio_track)
	return -1
