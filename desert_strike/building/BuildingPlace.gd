extends "res://parallax/util/ParallaxObject.gd"

signal place_structure(this)

var parallax_engine

var building_options = [
	preload("res://desert_strike/building/Archery.tscn"),
	preload("res://desert_strike/building/Farm.tscn"),
]

onready var rep = preload("res://desert_strike/building/ArcheryRepresentative.tscn")
const SELECTION_WIDTH = 4

var building_state = "archery"
onready var rep_instance = rep.instance()
var option_inxed
var option

func _ready(): 
	add_child(rep_instance)
	rep_instance.visible = false
	$BrownHelm.visible = true
	$GreenHelm.visible = false
	$Archer.visible = false
	$Farmer.visible = false
	labalize()

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
	var label_name = rep_instance.label_name
	labalize()

func labalize():
	$Label.text = "Q / E to switch.\nW to build " + label_name + " for 2gp."
