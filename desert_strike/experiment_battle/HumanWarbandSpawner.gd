extends WarbandSpawner

onready var Archer = load("res://desert_strike/creature/Archer.tscn")
onready var Farmer = load("res://desert_strike/creature/Farmer.tscn")

var num_farmers_to_spawn = 8
var num_archers_to_spawn = 16

func start_army(parallax_engine):
	army_dir = State.Dir.RIGHT
	set_army_start_offset(-4)
	initialize_army(parallax_engine)
	spawn_first_wave_no_gaps()
	return army_grid

func spawn_first_wave_no_gaps(): 
	add_new_creatures(Farmer, num_farmers_to_spawn)
	add_new_creatures(Archer,num_archers_to_spawn)

func spawn_first_wave_with_gaps(): 
	create_and_add_creature_to_lane_DEBUG(Archer, 0)
	army_grid.add_empty_slot_to_end_of_lane_DEBUG(0)
	create_and_add_creature_to_lane_DEBUG(Farmer, 0)
	create_and_add_creature_to_lane_DEBUG(Farmer, 0)
