extends Node2D

# TODO move functionality into other classes
# When the armies encounter each other, spawn an adjudicator
# pass the armies to the adjudicator 

var State = preload("res://desert_strike/State.gd")

const BATTLE_SEP = 10
const NUM_LANES = 4
onready var rng = RandomNumberGenerator.new()

var BuildingPlace = preload("res://desert_strike/building/BuildingPlace.tscn") 
var Farm = preload("res://desert_strike/building/Farm.tscn") 
var ArcheryTargets = preload("res://desert_strike/building/ArcheryTargets.tscn") 
var ArcheryTarget = preload("res://desert_strike/building/ArcheryTarget.tscn") 
var FarmerAtHut = preload("res://desert_strike/building/FarmerAtHut.tscn") 
var ArcherAtHut = preload("res://desert_strike/building/ArcherAtHut.tscn") 
var Checkpoint = preload("res://desert_strike/Checkpoint.tscn")

var checkpoints = [] # TOOD allow for multiple checkpoints

onready var parallax_engine = get_parent().get_node("Renderables/ParallaxEngine")

const TIME_BETWEEN_WAVES = 60

var wave_timer = 0 
var wave_num = 1

onready var factions = [$HumanFaction, $GlutFaction]
onready var player_faction = $HumanFaction

func _ready():
	# TODO when armies encounter each other, they should be converted between army types
	# I.e., Formation or Deployment
#
#	$HumanArmy.connect("defeat", self, "_human_defeat")
#	$GlutArmy.connect("defeat", self, "_glut_defeat")
#
#	$HumanArmy.set_army_start_offset(20)
#	$GlutArmy.set_army_start_offset(60)
#	$HumanArmy.start_army()
#	$GlutArmy.start_army()
#
	rng.randomize()
	create_building_places()
	create_checkpoints()
	
var tick_timer = 1.0

func _process(delta):
	pass
		
func create_building_places(): 
	# TODO Should this function be happening in the entity controller?
	create_building_places_at(range(0, -121, -12))

func create_building_places_at(x_poses):
	for x_pos in x_poses: 
		create_building_place_at(x_pos)

func create_building_place_at(x_pos): 
	var building_place = BuildingPlace.instance()
	building_place.real_pos.z = 9
	building_place.real_pos.x = x_pos
	add_child(building_place)
	building_place.connect("place_structure", self, "_on_building_place_structure")
	parallax_engine.add_object_to_parallax_world(building_place)
	building_place.set_parallax_engine(parallax_engine) # TODO this is hacky and wrong

func create_checkpoints(): 
	create_checkpoint(10, 1)
	create_checkpoint(40, 0)
	create_checkpoint(70, -1)
	create_checkpoint(100, -1)
	create_checkpoint(130, -1)
	
func create_checkpoint(checkpoint_pos, ownership): 
	var checkpoint = Checkpoint.instance()
	checkpoint.real_pos.z = 40
	checkpoint.real_pos.x = checkpoint_pos
	checkpoint.set_ownership(ownership)
	checkpoints.append(checkpoint)
	add_child(checkpoint)
	parallax_engine.add_object_to_parallax_world(checkpoint)
	
func _on_building_place_structure(building_place): 
	var new_building
	var new_person
	if building_place.building_state == "farm": 

		for i in range(0,3):
			new_building = Farm.instance()
			new_building.real_pos.z = 48 + i*8
			new_building.real_pos.x = building_place.real_pos.x
			add_child(new_building)
			parallax_engine.add_object_to_parallax_world(new_building)
		new_person = FarmerAtHut.instance()
#		$HumanArmy.add_farmers_to_spawn(2)
	else: 
		new_person = ArcherAtHut.instance()
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
	
func _on_person_at_hut_destroy_structure(person_at_hut): 
	create_building_place_at(person_at_hut.real_pos.x)
	parallax_engine.remove_object(person_at_hut.connected_structure)
	parallax_engine.remove_object(person_at_hut)

func _on_Faction_add_creatures_to_world(creatures):
	# creatures is a grid, but we need a list to iterate
	for creature in creatures.get_all_creatures():
		add_creature_to_world(creature)

func add_creature_to_world(creature): 
	creature.parallax_engine = parallax_engine
	add_child(creature)
	parallax_engine.add_object_to_parallax_world(creature)
	creature.connect("disappear", parallax_engine, "_on_object_disappear")
