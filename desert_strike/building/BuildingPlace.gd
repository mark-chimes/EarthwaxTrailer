extends "res://parallax/util/ParallaxObject.gd"

signal place_building(this)

var parallax_engine
const SELECTION_WIDTH = 8

# TODO building state is very hacky and should not even be here
var building_state = "archery"

func _ready(): 
	switch_building_state()
	$BrownHelm.visible = true
	$GreenHelm.visible = false

# TODO deprecate this and make a buildings controller
func set_parallax_engine(new_parallax_engine): 
	parallax_engine = new_parallax_engine
	
func _process(delta): 
	if parallax_engine.player_real_pos_x > -real_pos.x  - SELECTION_WIDTH\
			 and parallax_engine.player_real_pos_x < -real_pos.x + SELECTION_WIDTH:
		$BrownHelm.visible = false
		$GreenHelm.visible = true
		$Label.visible = true
		if Input.is_action_just_pressed("ui_accept"):
			print("Building building")
			emit_signal("place_building", self)
		if Input.is_action_just_pressed("ui_up") or Input.is_action_just_pressed("ui_down"):
			switch_building_state()
	else: 
		$BrownHelm.visible = true
		$GreenHelm.visible = false
		$Label.visible = false
		
# TODO Hacky
func switch_building_state(): 
	var label_name = ""
	if building_state == "farm": 
		building_state = "archery"
		label_name = "archery range"
	else: 
		building_state = "farm"
		label_name = "farm"
	$Label.text = "<Up/down> to switch.\n<space> to build " + label_name + "."
