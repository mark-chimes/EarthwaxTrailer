extends Node2D

signal defeat
signal attack(lane, damage)
signal front_line_ready(lane)
signal creature_death(lane)

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
	for i in range(0, NUM_LANES * BANDS_SPAWNED):
		add_creature()
	for creature in army_grid.get_all_creatures():
		creature.set_state(StateCreature.MARCH, army_dir)

func add_new_creatures(num_creatures): 
	var new_creatures = [] 
	for i in range(0, num_creatures):
		var creature = Creature.instance()
		army_grid.add_creature_to_shortest_lane(creature)
		var z_pos = (creature.lane * DISTANCE_BETWEEN_LANES) + 3 
		creature.real_pos.z = z_pos
		add_child(creature)
		creature.dir = army_dir
		creature.real_pos.x = (-army_dir * ARMY_HALF_SEP) \
				+ (-army_dir * creature.band * STARTING_BAND_SEP) + rng.randf_range(-2, 2)
		parallax_engine.add_object_to_parallax_world(creature)	
		new_creatures.append(creature)
		creature.connect("creature_positioned", self, "_on_creature_positioned")
		creature.connect("attack", self, "_on_creature_attack")
		creature.connect("death", self, "_creature_death")
		
	for creature in new_creatures:
		if state == StateArmy.BATTLE:
			position_creature(creature)
		else:
			creature.set_state(StateCreature.MARCH, army_dir)

func _process(delta):
	match state:
		StateArmy.MARCH:
			pass
		StateArmy.IDLE:
			for creature in army_grid.get_all_creatures(): 
				creature.set_state(StateCreature.IDLE, army_dir)
		StateArmy.BATTLE:
			pass
		StateArmy.DIE:
			pass

func _on_creature_attack(attacker): 
	# TODO different behaviour for melee vs ranged vs reach etc.
	# TODO When you have melee, reach, range need a way for attackers to know if there is a target
	# TODO need a way to know how to pick a good target, etc.	
	
	# The other army will know to attack the frontline of its lane
	emit_signal("attack", attacker.lane, attacker.damage)
	
func _on_get_attacked(lane_index, damage): 
	# TODO should not even be getting attacked if there is no frontline
#	if not enemy_army_grid.has_frontline_at_lane(lane_index): 
#		printerr("Null frontline creature being attacked in lane " + str(lane_index))
#		return	
	#var frontline_creature = enemy_army_grid.get_frontline_at_lane(lane_index)
	if not army_grid.has_frontline_at_lane(lane_index): 
		printerr("Null frontline creature being attacked in lane " + str(lane_index))
		return	
	army_grid.get_frontline_at_lane(lane_index).take_damage(damage)
		
func get_pos():
	# TODO Optimize this
	# TODO only needs the frontline
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

func add_creature():
	var creature = Creature.instance()
	army_grid.add_creature(creature)
	var z_pos = (creature.lane * DISTANCE_BETWEEN_LANES) + 3 
	creature.real_pos.z = z_pos
	add_child(creature)
	creature.dir = army_dir
	creature.real_pos.x = (-army_dir * ARMY_HALF_SEP) \
			+ (-army_dir * creature.band * STARTING_BAND_SEP) + rng.randf_range(-2, 2)
	parallax_engine.add_object_to_parallax_world(creature)
	creature.connect("creature_positioned", self, "_on_creature_positioned")
	creature.connect("attack", self, "_on_creature_attack")
	creature.connect("death", self, "_creature_death")

func battle(new_battlefronts, new_enemy_army_grid):
	state = StateArmy.BATTLE
	battlefronts = new_battlefronts
	enemy_army_grid = new_enemy_army_grid
	for creature in army_grid.get_all_creatures():
		position_creature(creature)

func get_state():
	return state
	
func _creature_death(dead_creature):
	emit_signal("creature_death", dead_creature.lane)
	dead_creature.disconnect("attack", self, "_on_creature_attack")
	dead_creature.disconnect("death", self, "_creature_death")

	# TODO this is just frontline, should also care about band
	var lane_index =  dead_creature.lane
	var lane = army_grid.get_lane(lane_index)
	lane.pop_front()
	for creature in lane: 
		creature.band -= 1
		position_creature(creature)
	
	# TODO defeat and routing mechanics: 
	if not has_creatures(): 
		emit_signal("defeat")
		
func idle():
	state = StateArmy.IDLE
	for creature in army_grid.get_all_creatures():
		creature.set_state(state, army_dir)

func position_creature(creature):
	var target_walk_x = get_target_x_from_band_lane(creature.band, creature.lane)
	creature.walk_to(target_walk_x)

func _on_creature_positioned(creature):
	if creature.band == 0:
		var enemy_creature = enemy_army_grid.get_frontline_at_lane(creature.lane)
		if enemy_creature.state == StateCreature.AWAIT_FIGHT:
			creature_fight(creature)
		else:
			creature.set_state(StateCreature.AWAIT_FIGHT, army_dir)
		emit_signal("front_line_ready", creature.lane)
	else:
		creature.set_state(StateCreature.IDLE, army_dir)

func has_creatures(): 
	return army_grid.has_creatures()

func get_target_x_from_band_lane(band, lane):
	var lane_offset = FIGHT_SEP + lane*1.0/10
	return battlefronts[lane] - (army_dir * (lane_offset + band * BAND_SEP))

func _on_front_line_ready(ready_lane):
	var creature = army_grid.get_frontline_at_lane(ready_lane)
	if creature.state == StateCreature.AWAIT_FIGHT:
		creature_fight(creature)
	
func creature_fight(creature):
	creature.set_state(StateCreature.FIGHT, army_dir)
	
func _on_enemy_creature_death(lane):
	var creature = army_grid.get_frontline_at_lane(lane)
	creature.set_state(StateCreature.AWAIT_FIGHT, army_dir)
	
#func get_frontline_at_lane(lane_num): 
#	# TODO What happens when creatures are removed from the array?
#	# TODO optimize this
#	return army_grid.get_creature_band_lane(0, lane_num)
#
