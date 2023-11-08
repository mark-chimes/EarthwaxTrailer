extends WarbandAttacking

var Grubling = load("res://desert_strike/creature/Grubling.tscn")

func _ready(): 
	pass

func start_army(): 
	army_dir = State.Dir.LEFT
	initialize_army()
	spawn_first_wave_no_gaps()

func spawn_first_wave_no_gaps(): 
	add_new_creatures(Grubling, 128)

func spawn_first_wave_with_gaps(): 
	create_and_add_creature_to_lane_DEBUG(Grubling, 0)
	army_grid.add_empty_slot_to_end_of_lane_DEBUG(0)
	create_and_add_creature_to_lane_DEBUG(Grubling, 0)
	create_and_add_creature_to_lane_DEBUG(Grubling, 0)
	army_grid.add_empty_slot_to_end_of_lane_DEBUG(0)
	army_grid.add_empty_slot_to_end_of_lane_DEBUG(0)
	army_grid.add_empty_slot_to_end_of_lane_DEBUG(0)
	
	army_grid.add_empty_slot_to_end_of_lane_DEBUG(1)
	create_and_add_creature_to_lane_DEBUG(Grubling, 1)
	create_and_add_creature_to_lane_DEBUG(Grubling, 1)
	create_and_add_creature_to_lane_DEBUG(Grubling, 1)
	army_grid.add_empty_slot_to_end_of_lane_DEBUG(1)
	
	create_and_add_creature_to_lane_DEBUG(Grubling, 2)
	create_and_add_creature_to_lane_DEBUG(Grubling, 2)
	army_grid.add_empty_slot_to_end_of_lane_DEBUG(2)
	create_and_add_creature_to_lane_DEBUG(Grubling, 2)
	create_and_add_creature_to_lane_DEBUG(Grubling, 2)
	army_grid.add_empty_slot_to_end_of_lane_DEBUG(2)
	
	create_and_add_creature_to_lane_DEBUG(Grubling, 3)
	army_grid.add_empty_slot_to_end_of_lane_DEBUG(3)
	army_grid.add_empty_slot_to_end_of_lane_DEBUG(3)
	army_grid.add_empty_slot_to_end_of_lane_DEBUG(3)
	create_and_add_creature_to_lane_DEBUG(Grubling, 3)
	create_and_add_creature_to_lane_DEBUG(Grubling, 3)
	create_and_add_creature_to_lane_DEBUG(Grubling, 3)
