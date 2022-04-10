extends "res://parallax/util/ParallaxObject.gd"

onready var LabelForPerson = preload("res://desert_strike/building/LabelForPersonAtHut.tscn")
var label
var parallax_engine
const SELECTION_WIDTH = 8

func _ready(): 
	label = LabelForPerson.instance()
	add_child(label) 

func set_label_text(new_text): 
	label.get_node("Label").set_text(new_text)
	
# TODO deprecate this and make a buildings controller
func set_parallax_engine(new_parallax_engine): 
	parallax_engine = new_parallax_engine
	
func _process(delta): 
	if parallax_engine.player_real_pos_x > -real_pos.x  - SELECTION_WIDTH\
			 and parallax_engine.player_real_pos_x < -real_pos.x + SELECTION_WIDTH:
		label.visible = true
	else: 
		label.visible = false
