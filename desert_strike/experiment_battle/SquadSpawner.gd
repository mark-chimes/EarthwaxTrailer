extends Node2D
class_name SquadSpawner

signal front_line_ready(shared_lane)
signal add_creature_to_world(creature)

var ArmyGrid = preload("res://desert_strike/army/ArmyGrid.gd")
var State = preload("res://desert_strike/State.gd")

var rng = null

var battlefronts = []
var idle_point = 0

var army_grid = null

const BANDS_SPAWNED = 1
const NUM_LANES = 4
const DISTANCE_BETWEEN_LANES = 4
const ARMY_HALF_SEP = 10
const BAND_SEP = 3
const STARTING_BAND_SEP = 8

const FIGHT_SEP = 1
const END_POS_DELTA = 0.1

var army_start_offset = -40
var army_dir = State.Dir.RIGHT

func set_army_start_offset(new_army_start_offset):
	army_start_offset = new_army_start_offset
	idle_point = army_start_offset

func initialize_army(): 
	# parallax_engine = the_parallax_engine
	rng = RandomNumberGenerator.new()
	rng.set_seed(hash("42069"))
	army_grid = ArmyGrid.new()
	army_grid.initialize(NUM_LANES)

func add_new_creatures(CreatureType, num_creatures): 
	var new_creatures = [] 
	for i in range(0, num_creatures):
		_create_and_add_creature(new_creatures, CreatureType)
	for creature in new_creatures:
		creature.set_state(State.Creature.IDLE, army_dir)
	return new_creatures

func _create_and_add_creature(creatures_arr, CreatureType): 
	var creature = CreatureType.instance()
	army_grid.add_creature_to_smallest_lane(creature)
	var z_pos = (creature.lane * DISTANCE_BETWEEN_LANES) + 3 
	creature.real_pos.z = z_pos
	creature.dir = army_dir
	creature.real_pos.x = (-army_dir * ARMY_HALF_SEP) \
			+ (-army_dir * creature.band * STARTING_BAND_SEP) + rng.randf_range(-2, 2)\
			+ army_start_offset
	creatures_arr.append(creature)
	emit_signal("add_creature_to_world", creature)
