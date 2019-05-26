extends Node

func randf_range(float_min, float_max):
	randomize()
	var the_range = float_max - float_min
	var the_ratio = the_range * randf()
	return float_min + the_ratio