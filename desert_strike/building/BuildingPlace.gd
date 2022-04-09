extends "res://parallax/util/ParallaxObject.gd"

var parallax_engine
const SELECTION_WIDTH = 8

# TODO deprecate this and make a buildings controller
func set_parallax_engine(new_parallax_engine): 
	parallax_engine = new_parallax_engine
	
func _process(delta): 
	if parallax_engine.player_real_pos_x > -real_pos.x  - SELECTION_WIDTH\
			 and parallax_engine.player_real_pos_x < -real_pos.x + SELECTION_WIDTH:
		var color = Color8(255, 0, 0, 255)
		$BoulderTransparent.modulate = color
	else: 
		var color = Color8(255, 255, 255, 255)
		$BoulderTransparent.modulate = color
