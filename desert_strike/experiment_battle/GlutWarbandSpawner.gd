extends WarbandSpawner

var Grubling = load("res://desert_strike/creature/Grubling.tscn")

func start_army(parallax_engine):
	army_dir = State.Dir.LEFT
	set_army_start_offset(4)
	initialize_army(parallax_engine)
	spawn_first_wave_no_gaps()
	return army_grid

func spawn_first_wave_no_gaps(): 
	add_new_creatures(Grubling, 8)

func spawn_first_wave_with_gaps(): 
	create_and_add_creature_to_lane_DEBUG(Grubling, 0)
	army_grid.add_empty_slot_to_end_of_lane_DEBUG(0)
	create_and_add_creature_to_lane_DEBUG(Grubling, 0)
	create_and_add_creature_to_lane_DEBUG(Grubling, 0)
