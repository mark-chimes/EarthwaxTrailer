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

# MARCHING SQUADS CANNOT BE REINFORCED
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
	
#func has_creatures(): 
#	return army_grid.has_creatures()
