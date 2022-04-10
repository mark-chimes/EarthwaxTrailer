extends "res://parallax/util/ParallaxObject.gd"

onready var LabelForPerson = preload("res://desert_strike/building/LabelForPersonAtHut.tscn")
var label
var parallax_engine
const SELECTION_WIDTH = 8

const FADE_SPEED = 2
const MAX_SPEECH_TIME = 3

var is_fading = false
var speech_time = MAX_SPEECH_TIME
var has_spoken = false
var fade = 1

func _ready(): 
	label = LabelForPerson.instance()
	add_child(label) 

func set_label_text(new_text): 
	print("Setting text")
	label.get_node("Label").set_text(new_text)
	
# TODO deprecate this and make a buildings controller
func set_parallax_engine(new_parallax_engine): 
	parallax_engine = new_parallax_engine
	
func _process(delta): 
	if parallax_engine.player_real_pos_x > -real_pos.x  - SELECTION_WIDTH\
			 and parallax_engine.player_real_pos_x < -real_pos.x + SELECTION_WIDTH:
		if not has_spoken:
			has_spoken = true
			speech_time = MAX_SPEECH_TIME
			fade = 1
			label.modulate = Color(1,1,1,1)
			label.visible = true
			return

		if speech_time > 0: 
			speech_time -= delta
			return
		
		if fade > 0: 
			fade -= FADE_SPEED*delta
			label.modulate = Color(1,1,1,fade)
			return
			
		label.visible = false
		return

	has_spoken = false
	if fade > 0: 
		fade -= FADE_SPEED*delta
		label.modulate = Color(1,1,1,fade)
		return
