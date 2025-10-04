extends BlockData
class_name CropData

@export var duration : float

func growth_index(time : float):
	var stage_index : int = int( (time / duration) * (atlas_coords.size() -1) )
	return stage_index
