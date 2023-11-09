extends Object
class_name SquadDefending

var ArmyGrid = preload("res://desert_strike/army/ArmyGrid.gd")
var State = preload("res://desert_strike/State.gd")

#var rng = null

var army_grid = null
var army_dir = State.Dir.RIGHT

# GRID MUST CONTAIN UNITS! 
func initialize_army_from_grid(starting_army_grid, starting_army_dir):
	army_grid = starting_army_grid
	army_dir = starting_army_dir
	initialize_all_creatures()

func initialize_all_creatures(): 
	for creature in army_grid.get_all_creatures():
		creature.set_state(State.Creature.IDLE, army_dir)

func get_front_of_squad(): 
	# TODO optimize this - It should know where it is and units 
	# should mill around it.
	
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

func reinforce_squad(new_creatures): 
	_add_new_creatures_from_list(new_creatures)
	for creature in new_creatures:
		creature.set_state(State.Creature.IDLE, army_dir)
		# position_creature(creature)

# This is for internal use, adding the creatures and intializing their signals
func _add_new_creatures_from_list(new_creatures): 
	for creature in new_creatures: 
		army_grid.add_creature_to_smallest_lane(creature)
		creature.dir = army_dir
	
func has_creatures(): 
	return army_grid.has_creatures()
