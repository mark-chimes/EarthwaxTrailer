extends Node

var ArcheryTargets = preload("res://desert_strike/building/ArcheryTargets.tscn") 
var ArcheryTarget = preload("res://desert_strike/building/ArcheryTarget.tscn") 
var FarmerAtHut = preload("res://desert_strike/building/FarmerAtHut.tscn") 
var ArcherAtHut = preload("res://desert_strike/building/ArcherAtHut.tscn") 
var Farm = preload("res://desert_strike/building/Farm.tscn") 
onready var parallax_engine = get_parent().get_parent().get_parent().get_node("Renderables/ParallaxEngine") #TODO Hahcky
var BuildingPlace = preload("res://desert_strike/building/BuildingPlace.tscn") 
var valid_building_positions = []
var x_pos_range = range(0, -121, -12)

func _ready():
	for x_pos in x_pos_range: 
		create_building_place_at(x_pos)


func create_building_place_at(x_pos): 
	var building_place = BuildingPlace.instance()
	building_place.real_pos.z = 9
	building_place.real_pos.x = x_pos
	add_child(building_place)
	building_place.connect("place_structure", self, "_on_building_place_structure")
	parallax_engine.add_object_to_parallax_world(building_place)
	building_place.set_parallax_engine(parallax_engine) # TODO this is hacky and wrong

func _on_person_at_hut_destroy_structure(person_at_hut): 
	create_building_place_at(person_at_hut.real_pos.x)
	parallax_engine.remove_object(person_at_hut.connected_structure)
	parallax_engine.remove_object(person_at_hut)

func _on_building_place_structure(building_place): 
	var new_building
	var new_person = building_place.rep_instance.person_at_hut.instance()
	if building_place.building_state == "farm": 
		for i in range(0,3):
			new_building = Farm.instance()
			new_building.real_pos.z = 48 + i*8
			new_building.real_pos.x = building_place.real_pos.x
			add_child(new_building)
			parallax_engine.add_object_to_parallax_world(new_building)
#		$HumanArmy.add_farmers_to_spawn(2)
	else: 
#		$HumanArmy.add_archers_to_spawn(2)

		new_building = ArcheryTargets.instance()
		new_building.real_pos.z = 48
		new_building.real_pos.x = building_place.real_pos.x
		add_child(new_building)
		parallax_engine.add_object_to_parallax_world(new_building)
		
		new_building = ArcheryTarget.instance()
		new_building.real_pos.z = 64
		new_building.real_pos.x = building_place.real_pos.x
		add_child(new_building)
		parallax_engine.add_object_to_parallax_world(new_building)

	new_person.connect("destroy_structure", self, "_on_person_at_hut_destroy_structure")
	new_person.set_connected_structure(new_building)
	new_person.real_pos.z = building_place.real_pos.z
	new_person.real_pos.x = building_place.real_pos.x
	new_person.set_parallax_engine(parallax_engine)
	# TODO everything with objects and children should go via "Renderables"
	parallax_engine.add_object_to_parallax_world(new_person)
	add_child(new_person)
	
	parallax_engine.remove_object(building_place)
