extends "res://parallax/util/ParallaxObject.gd"

signal place_structure(this)

var parallax_engine

var building_options = [
	preload("res://desert_strike/building/ArcheryRepresentative.tscn"),
	preload("res://desert_strike/building/FarmRepresentative.tscn"),
]
var option_index = 0
var rep
var rep_instance

const SELECTION_WIDTH = 4

var building_state = "archery"

func _ready(): 
	create_new_rep(0)
	rep_instance.visible = false
	$BrownHelm.visible = true
	$GreenHelm.visible = false
	$Archer.visible = false
	$Farmer.visible = false

# TODO deprecate this and make a buildings controller
func set_parallax_engine(new_parallax_engine): 
	parallax_engine = new_parallax_engine
	
func _process(delta): 
	$BrownHelm.visible = true
	$Label.visible = false
	rep_instance.visible = false
	if parallax_engine.player_real_pos_x > -real_pos.x  - SELECTION_WIDTH\
			 and parallax_engine.player_real_pos_x < -real_pos.x + SELECTION_WIDTH:
		rep_instance.visible = true
		rep_instance.modulate = Color(0.2,1,0.2,1)
		$BrownHelm.visible = false
		$Label.visible = true
		if Input.is_action_just_pressed("selection_confirm"):
			print("Building structure")
			emit_signal("place_structure", self)
		if Input.is_action_just_pressed("selection_left"):
			switch_building_state(true)
		if Input.is_action_just_pressed("selection_right"):
			switch_building_state(false)
		
# TODO Hacky
func switch_building_state(is_next): 
	var num_options = building_options.size()
	if is_next: 
		option_index += 1
	else:
		option_index -= 1
	option_index = posmod(option_index, num_options)

	rep_instance.queue_free()
	create_new_rep(option_index)
	
func create_new_rep(index):
	rep = building_options[option_index]
	rep_instance = rep.instance()
	add_child(rep_instance)
	var label_name = rep_instance.label_name
	labalize(label_name)

func labalize(label_name):
	$Label.text = "Q / E to switch.\nW to build " + label_name + " for 2gp."
