extends "res://parallax/util/ParallaxObject.gd"

var band
var lane

func set_band_lane(new_band, new_lane): 
	band = new_band
	lane = new_lane

func set_band(new_band): 
	set_band_lane(new_band, lane)
	
func set_lane(new_lane): 
	set_band_lane(band, new_lane)
