extends Node2D

signal defeat
signal attack(band, lane, damage)
signal front_line_ready(lane)
signal creature_death(band, lane)

var ArmyGrid = preload("res://desert_strike/ArmyGrid.gd")

# var creature = preload("res://desert_strike/creature/creature.tscn")
var Creature
onready var parallax_engine = get_parent().get_parent().get_node("ParallaxEngine")
onready var rng = RandomNumberGenerator.new()

var battlefronts = []

onready var army_grid = ArmyGrid.new()
var enemy_army_grid

# TODO Special parallax converter subobject for grid army positions to real positions. 

enum Dir {
	LEFT = -1,
	RIGHT = 1,
}

enum StateCreature {
	MARCH,
	WALK,
	AWAIT_FIGHT,
	FIGHT,
	IDLE,
	DIE,
}

enum StateArmy {
	MARCH,
	BATTLE,
	IDLE,
	DIE,
}

var state = StateArmy.IDLE

const BANDS_SPAWNED = 1
const NUM_LANES = 4
const DISTANCE_BETWEEN_LANES = 4
const ARMY_HALF_SEP = 20
const BAND_SEP = 3
const STARTING_BAND_SEP = 8
const FIGHT_SEP = 1
const END_POS_DELTA = 0.1

var dead_creatures = 0
var defeat_threshold = NUM_LANES
var army_dir = Dir.RIGHT

func initialize_army(): 
	rng.set_seed(hash("42069"))
	army_grid.initialize(NUM_LANES)
	state = StateArmy.MARCH

func _on_creature_attack(attacker): 
	if attacker.is_ranged and attacker.band != 0:
		# Ranged attack
		if attacker.ranged_target_band == null or attacker.ranged_target_lane == null: 
			printerr("Ranged attacker at " + str(attacker.band) + ", " + str(attacker.lane) + " targeting null")
			
		if not enemy_army_grid.has_creature_at(attacker.ranged_target_band, attacker.ranged_target_lane):
			return
		emit_signal("attack", attacker.ranged_target_band, attacker.ranged_target_lane, attacker.ranged_damage)
	else: 	
		# melee attack so band is 0
		emit_signal("attack", 0, attacker.lane, attacker.melee_damage)
	
func _on_get_attacked(band_index, lane_index, damage): 
	if not army_grid.has_creature_at(band_index, lane_index): 
		printerr("Null creature being attacked in band_lane (" + str(band_index) + ", " + str(lane_index) + ")")
		return
	army_grid.get_creature_band_lane(band_index, lane_index).take_damage(damage)
		
func get_pos():
	var creatures = army_grid.get_front_creatures()
	var front_pos = creatures[0].real_pos.x
	if army_dir == Dir.RIGHT:
		for creature in creatures: 
			if creature.real_pos.x > front_pos:
				front_pos = creature.real_pos.x
	else: 
		for creature in creatures: 
			if creature.real_pos.x < front_pos:
				front_pos = creature.real_pos.x
	return front_pos

func add_new_creatures(CreatureType, num_creatures): 
	var new_creatures = [] 
	for i in range(0, num_creatures):
		create_and_add_creature(new_creatures, CreatureType)
	if state == StateArmy.BATTLE:
		sort_and_position_army()
	else:
		for creature in new_creatures:
			creature.set_state(StateCreature.MARCH, army_dir)
		# sort_creatures()
	return new_creatures

func create_and_add_creature(creatures_arr, CreatureType): 
	var creature = CreatureType.instance()
	army_grid.add_creature_to_shortest_lane(creature)
	var z_pos = (creature.lane * DISTANCE_BETWEEN_LANES) + 3 
	creature.real_pos.z = z_pos
	add_child(creature)
	creature.dir = army_dir
	creature.real_pos.x = (-army_dir * ARMY_HALF_SEP) \
			+ (-army_dir * creature.band * STARTING_BAND_SEP) + rng.randf_range(-2, 2)
	parallax_engine.add_object_to_parallax_world(creature)	
	creatures_arr.append(creature)
	creature.connect("creature_positioned", self, "_on_creature_positioned")
	creature.connect("attack", self, "_on_creature_attack")
	creature.connect("death", self, "_on_creature_death")
	creature.connect("disappear", parallax_engine, "_on_object_disappear")
	if creature.is_ranged: 
		creature.connect("fire_projectile", self, "_on_creature_fire_projectile")
		
func _on_creature_fire_projectile(archer_pos, target_band, target_lane, projectile): 
	var start_x = archer_pos.x
	
	var lane_offset = FIGHT_SEP + target_lane*1.0/10
	var end_x =  battlefronts[target_lane] + (army_dir * (lane_offset + target_band * BAND_SEP))
	var total_dist = end_x - start_x
	projectile.real_pos.y = -1.5
	projectile.real_pos.x = start_x 
	projectile.real_pos.z = archer_pos.z
	var frames = 7
	var travel_time = total_dist / 20.0
	
	projectile.horizontal_speed = total_dist / travel_time
	projectile.end_x = end_x
	projectile.vertical_speed = -projectile.horizontal_speed
	projectile.vertical_acc = -2*projectile.vertical_speed / (travel_time)
	projectile.rot_dist = total_dist / (frames + 1)
	projectile.is_flying = true
	
	add_child(projectile)
	parallax_engine.add_object_to_parallax_world(projectile)
	projectile.connect("disappear", parallax_engine, "_on_projectile_disappear")
	
func battle(new_battlefronts, new_enemy_army_grid):
	state = StateArmy.BATTLE
	battlefronts = new_battlefronts
	enemy_army_grid = new_enemy_army_grid
	sort_and_position_army()

func get_state():
	return state
	
func _on_creature_death(dead_creature):
	emit_signal("creature_death", dead_creature.band, dead_creature.lane)
	dead_creature.disconnect("attack", self, "_on_creature_attack")
	dead_creature.disconnect("death", self, "_creature_death")

	var lane_index =  dead_creature.lane
	var band_index = dead_creature.band
	var lane = army_grid.get_lane(lane_index)
	
	lane.remove(band_index)
	# move everyone behind me forwards
	for i in range(band_index, len(lane)): 
		var creature = lane[i]
		creature.set_band(i)
	sort_and_position_lane(lane)

	# TODO defeat and routing mechanics: 
	if not has_creatures(): 
		emit_signal("defeat")
		
func idle():
	state = StateArmy.IDLE
	for creature in army_grid.get_all_creatures():
		creature.set_state(StateCreature.IDLE, army_dir)

func position_creature(creature):
	var target_walk_x = get_target_x_from_band_lane(creature.band, creature.lane)
	creature.walk_to(target_walk_x)

func _on_creature_positioned(creature):
	if creature.band == 0:
		if not enemy_army_grid.has_frontline_at_lane(creature.lane): 
			creature.set_state(StateCreature.IDLE, army_dir)
			return
		var enemy_creature = enemy_army_grid.get_frontline_at_lane(creature.lane)

		if enemy_creature.state == StateCreature.AWAIT_FIGHT:
			creature_fight(creature)
		else:
			creature.set_state(StateCreature.AWAIT_FIGHT, army_dir)
		emit_signal("front_line_ready", creature.lane)
	else:
		if creature.is_ranged: 
			var enemy_creature = enemy_army_grid.get_archery_target(creature.lane, creature.attack_range)
			if enemy_creature == null:
				creature.set_state(StateCreature.IDLE, army_dir)
				return
			# TODO wait for enemy to get into position etc. 
			creature_fire_arrow(creature, enemy_creature.band, enemy_creature.lane)
		else: 
			creature.set_state(StateCreature.IDLE, army_dir)

func has_creatures(): 
	return army_grid.has_creatures()

func get_target_x_from_band_lane(band, lane):
	var lane_offset = FIGHT_SEP + lane*1.0/10
	return battlefronts[lane] - (army_dir * (lane_offset + band * BAND_SEP))

func _on_front_line_ready(ready_lane):
	var creature = army_grid.get_frontline_at_lane(ready_lane)
	if creature.is_positioned(): 
		if creature.state == StateCreature.AWAIT_FIGHT:
			creature_fight(creature)
	else: 
		position_creature(creature)
	
func creature_fight(creature):
	creature.set_state(StateCreature.FIGHT, army_dir)
	
func creature_fire_arrow(creature, enemy_band, enemy_lane):
	enemy_band > enemy_lane # Try to crash if this is null
	creature.set_archery_target_band_lane(enemy_band, enemy_lane) 
	creature.set_state(StateCreature.FIGHT, army_dir)
	
func _on_enemy_creature_death(band_index, lane_index):
	if band_index == 0: 
		sort_and_position_lane(army_grid.get_lane(lane_index))
		
func sort_and_position_army(): 
	for lane in army_grid.creature_lanes: # TODO get this variable better? 
		sort_and_position_lane(lane)

func sort_and_position_lane(lane): 
	sort_lane(lane)
	for creature in lane: 
		position_creature(creature)
	
# TODO this sorting code should probably be handled elsewhere?
func sort_creatures(): 
	for lane in army_grid.creature_lanes: # TODO get this variable better? 
		sort_lane(lane)

func sort_lane(lane): 
	# we'll just use bubble sort for now since array size is small
	# bubble sort is also a stable sort
	
	# if there is just one element it's already sorted
	if len(lane) <= 1: 
		return
	
	var n = len(lane)
	for i in range(n-1): 
		for j in range(0, n-i-1): 
			if should_creature_1_be_further_back(lane[j], lane[j + 1]):
				var temp = lane[j]
				lane[j] = lane[j + 1]
				lane[j].set_band(j)
				lane[j + 1] = temp
				lane[j + 1].set_band(j+1)
				
func should_creature_1_be_further_back(creature1, creature2): 
	# higher priority to the front
	# but front is a lower index
	if creature1.state in [StateCreature.FIGHT, StateCreature.AWAIT_FIGHT]\
			and not creature2.state in [StateCreature.FIGHT, StateCreature.AWAIT_FIGHT]:
		return false
		
	if not creature1.state in [StateCreature.FIGHT, StateCreature.AWAIT_FIGHT]\
			and creature2.state in [StateCreature.FIGHT, StateCreature.AWAIT_FIGHT]: 
		return true
		
	return creature1.priority < creature2.priority
