extends Node
class_name SquadSpawner

var ArmyGrid = preload("res://desert_strike/army/ArmyGrid.gd")
var State = preload("res://desert_strike/State.gd")

var rng = null

var battlefronts = []

var army_grid = null

const BANDS_SPAWNED = 1
const NUM_LANES = 4
const DISTANCE_BETWEEN_LANES = 4
const ARMY_HALF_SEP = 10
const BAND_SEP = 3
const STARTING_BAND_SEP = 8

const FIGHT_SEP = 1
const END_POS_DELTA = 0.1

export var army_start_offset = -40
export var num_creatures_to_spawn = 4 

func generate_squad(creature_type, num_creatures_to_spawn, dir):
	initialize_army()
	add_new_creatures(creature_type, num_creatures_to_spawn, dir)
	return army_grid
	
func initialize_army(): 
	# parallax_engine = the_parallax_engine
	rng = RandomNumberGenerator.new()
	rng.set_seed(hash("42069"))
	army_grid = ArmyGrid.new()
	army_grid.initialize(NUM_LANES)

func add_new_creatures(CreatureType, num_creatures, dir): 
	var new_creatures = [] 
	for i in range(0, num_creatures):
		_create_and_add_creature(new_creatures, CreatureType, dir)
	for creature in new_creatures:
		creature.set_state(State.Creature.IDLE, dir)
	return new_creatures

func _create_and_add_creature(creatures_arr, CreatureType, dir): 
	var creature = CreatureType.instance()
	army_grid.add_creature_to_smallest_lane(creature)
	var z_pos = (creature.lane * DISTANCE_BETWEEN_LANES) + 3 
	creature.real_pos.z = z_pos
	creature.dir = dir
	creature.real_pos.x = (-dir * ARMY_HALF_SEP) \
			+ (-dir * creature.band * STARTING_BAND_SEP) + rng.randf_range(-2, 2)\
			+ army_start_offset
	creatures_arr.append(creature)
