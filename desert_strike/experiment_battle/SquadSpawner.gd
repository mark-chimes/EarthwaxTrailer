extends Node2D
class_name SquadSpawner

signal front_line_ready(shared_lane)

var ArmyGrid = preload("res://desert_strike/army/ArmyGrid.gd")
var State = preload("res://desert_strike/State.gd")

# var creature = preload("res://desert_strike/creature/creature.tscn")

var parallax_engine = null
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

func initialize_army(the_parallax_engine): 
	parallax_engine = the_parallax_engine
	rng = RandomNumberGenerator.new()
	rng.set_seed(hash("42069"))
	army_grid = ArmyGrid.new()
	army_grid.initialize(NUM_LANES)

func add_new_creatures(CreatureType, num_creatures): 
	var new_creatures = [] 
	for i in range(0, num_creatures):
		create_and_add_creature(new_creatures, CreatureType)
	for creature in new_creatures:
		creature.set_state(State.Creature.IDLE, army_dir)
	return new_creatures

func create_and_add_creature_to_lane_DEBUG(CreatureType, lane_index): 
	var creature = CreatureType.instance()
	army_grid.add_creature_to_lane(creature, lane_index)
	var z_pos = (creature.lane * DISTANCE_BETWEEN_LANES) + 3 
	creature.parallax_engine = parallax_engine
	creature.real_pos.z = z_pos
	add_child(creature)
	creature.dir = army_dir
	creature.real_pos.x = (-army_dir * ARMY_HALF_SEP) \
			+ (-army_dir * creature.band * STARTING_BAND_SEP) + rng.randf_range(-2, 2)\
			+ army_start_offset
	parallax_engine.add_object_to_parallax_world(creature)	
	creature.set_state(State.Creature.IDLE, army_dir)

func create_and_add_creature(creatures_arr, CreatureType): 
	var creature = CreatureType.instance()
	army_grid.add_creature_to_smallest_lane(creature)
	var z_pos = (creature.lane * DISTANCE_BETWEEN_LANES) + 3 
	creature.parallax_engine = parallax_engine
	creature.real_pos.z = z_pos
	add_child(creature)
	creature.dir = army_dir
	creature.real_pos.x = (-army_dir * ARMY_HALF_SEP) \
			+ (-army_dir * creature.band * STARTING_BAND_SEP) + rng.randf_range(-2, 2)\
			+ army_start_offset
	parallax_engine.add_object_to_parallax_world(creature)	
	creatures_arr.append(creature)
	
func idle():
	for creature in army_grid.get_all_creatures():
		creature.set_state(State.Creature.IDLE, army_dir)

func has_creatures(): 
	return army_grid.has_creatures()

func position_creature(creature):
	# TODO this should work differently during battle and during idle time
	var target_walk_x = get_target_x_from_band_lane(creature.band, creature.lane)
	var target_walk_z = get_target_z_from_band_lane(creature.band, creature.lane)
	creature.walk_to(target_walk_x, target_walk_z)
	
func get_target_x_from_band_lane(band, lane):
	var lane_offset = FIGHT_SEP + lane*1.0/10
	return idle_point - (army_dir * (lane_offset + band * BAND_SEP))
		
func get_target_z_from_band_lane(band, lane):
	return (lane * DISTANCE_BETWEEN_LANES) + 3 

func _on_creature_positioned(creature):
	reconsider_state(creature)

func reconsider_state(creature): 
	creature.set_state(State.Creature.IDLE, army_dir)
