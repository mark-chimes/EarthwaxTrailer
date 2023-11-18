extends "res://parallax/util/ParallaxObject.gd"

signal place_structure(this)

var parallax_engine
enum BuildingOptions {
	FARM,
	ARCHERY,
}

var building_options = [
	preload("res://desert_strike/building/Archery.tscn"),
]

var building_option = building_options[0]
onready var rep = preload("res://desert_strike/building/ArcheryRepresentative.tscn")
const SELECTION_WIDTH = 4

var building_state = "archery"
onready var rep_instance = rep.instance()

func _ready(): 
	add_child(rep_instance)
	rep_instance.visible = true
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
	if parallax_engine.player_real_pos_x > -real_pos.x  - SELECTION_WIDTH\
			 and parallax_engine.player_real_pos_x < -real_pos.x + SELECTION_WIDTH:
		rep_instance.visible = true
		$BrownHelm.visible = false
		$Label.visible = true
		if Input.is_action_just_pressed("ui_accept"):
			print("Building structure")
			emit_signal("place_structure", self)
		if Input.is_action_just_pressed("ui_up") or Input.is_action_just_pressed("ui_down"):
			switch_building_state(0)
		
# TODO Hacky
func switch_building_state(building_option): 
	var num_options = building_options.size()
	building_option += 1
	if building_option >= num_options:
		building_option = 0
	building_option = 0

	var label_name = ""
	$Label.text = "<Up/down> to switch.\n<space> to build " + label_name + " for 2gp."
