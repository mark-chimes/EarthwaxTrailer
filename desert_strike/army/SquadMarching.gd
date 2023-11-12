extends Object
class_name SquadMarching

var ArmyGrid = preload("res://desert_strike/army/ArmyGrid.gd")
var State = preload("res://desert_strike/State.gd")

#var rng = null

var army_grid = null
var army_dir = State.Dir.RIGHT

#func initialize_squad_from_list(first_squad_start_offset, creatures_in_squad, starting_squad_dir, num_lanes):
#	# parallax_engine = starting_parallax_engine
#	army_grid = ArmyGrid.new()
#	army_grid.initialize(num_lanes)
#	army_dir = starting_squad_dir
#	_add_new_creatures_from_list(creatures_in_squad)
#	rng = RandomNumberGenerator.new()
#	rng.set_seed(hash("42069"))
#	# state = State.Army.MARCH
#	is_initialized = true

# GRID MUST CONTAIN UNITS! 
func initialize_army_from_grid(starting_army_grid, starting_army_dir):
	# parallax_engine = starting_parallax_engine
	army_grid = starting_army_grid
	army_dir = starting_army_dir
#	rng = RandomNumberGenerator.new()
#	rng.set_seed(hash("42069"))
	# state = State.Army.MARCH
	initialize_all_creatures()

func initialize_all_creatures(): 
	for creature in army_grid.get_all_creatures():
		creature.set_state(State.Creature.MARCH, army_dir)

func get_front_of_squad(): 
	# TODO optimize this - the squad should "MARCH" and its front should change rather than 
	# recalculating from all the units in it. It should know where it is.
	
	var creatures = army_grid.get_all_creatures()
	var front_pos
	if army_dir == State.Dir.RIGHT:
		# TODO hacky
		front_pos = creatures[0].real_pos.x
		for creature in creatures: 
			if creature.real_pos.x > front_pos:
				front_pos = creature.real_pos.x
	else: 
		front_pos = creatures[0].real_pos.x
		for creature in creatures: 
			if creature.real_pos.x < front_pos:
				front_pos = creature.real_pos.x
	return front_pos	

# MARCHING SQUADS CANNOT BE REINFORCED RIGHT NOW
#func reinforce_squad(new_creatures): 
#	_add_new_creatures_from_list(new_creatures)
#	for creature in new_creatures:
#		creature.set_state(State.Creature.MARCH, army_dir)
#		# position_creature(creature)

# This is for internal use, adding the creatures and intializing their signals
#func _add_new_creatures_from_list(new_creatures): 
#	for creature in new_creatures: 
#		army_grid.add_creature_to_smallest_lane(creature)
#		creature.dir = army_dir
	
func has_creatures(): 
	return army_grid.has_creatures()
