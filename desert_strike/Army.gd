extends Node2D

signal defeat

# var creature = preload("res://desert_strike/creature/creature.tscn")
var Creature
onready var parallax_engine = get_parent().get_parent().get_node("ParallaxEngine")
onready var rng = RandomNumberGenerator.new()
var frontline_func = null
var battlefronts = []

enum Dir {
	LEFT = -1,
	RIGHT = 1,
}

enum StateCreature {
	WALK,
	FIGHT,
	IDLE,
	DIE,
}

enum StateArmy {
	WALK,
	FIGHT,
	IDLE,
	DIE,
}

var state = StateArmy.IDLE

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

# Assume no gaps in a given lane
var creature_lanes = []
var adding_lane_index = 0
var adding_band_index = 0

func get_creature_band_lane(band_index, lane_index): 
	var lane = creature_lanes[lane_index]
	var creature = lane[band_index]
	# TODO What if no creature there? 
	return creature

func get_all_creatures():
	# TODO optimize?  
	var all_creatures = []
	for lane in creature_lanes:
		for creature in lane: 
			all_creatures.append(creature)
	return all_creatures

func initialize_army(): 
	rng.set_seed(hash("42069"))
	for i in range(0, NUM_LANES): 
		creature_lanes.append([])
	for i in range(0, NUM_LANES + 12):
		add_creature()
	state = StateArmy.WALK
	for creature in get_all_creatures():
		creature.set_state(StateCreature.WALK, army_dir)

func _process(delta):
	match state:
		StateArmy.WALK:
			pass
		StateArmy.IDLE:
			pass
		StateArmy.FIGHT:
			for lane_index in range(len(creature_lanes)): 
				var lane = creature_lanes[lane_index]
				var lane_offset = FIGHT_SEP + lane_index*1.0/10
				var front_enemy = frontline_func.call_func(lane_index)
				
				for band_index in range(len(lane)):
					var creature = lane[band_index]
					
					if not creature.state == StateCreature.WALK:
						continue
						
					if band_index == 0: 

						# var front_enemy_pos = front_enemy.real_pos.x
						# TODO - absolute grid army positions
						if abs(creature.real_pos.x - (battlefronts[lane_index] - (army_dir * lane_offset))) < END_POS_DELTA: 
							# connect signal for attack
							creature.connect("attack", front_enemy, "take_damage")
							creature.set_state(StateCreature.FIGHT, army_dir)
							creature.connect("death", self, "_creature_death")
					else: # Not a frontline unit 
						var goal_x = battlefronts[lane_index] - (army_dir * (lane_offset + band_index * BAND_SEP))
						
						if abs(creature.real_pos.x - goal_x) < END_POS_DELTA: 
							creature.set_state(StateCreature.IDLE, army_dir)
							
		StateArmy.DIE:
			pass

func get_pos():
	# TODO Optimize this
	# TODO only needs the frontline
	var creatures = get_all_creatures()
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
	if adding_lane_index >= NUM_LANES:
		adding_band_index += 1
		adding_lane_index = 0
	var z_pos = (adding_lane_index * DISTANCE_BETWEEN_LANES) + 3 
	var creature = Creature.instance()
	creature.set_rng(rng)
	creature_lanes[adding_lane_index].append(creature)
	add_child(creature)
	creature.dir = army_dir
	creature.real_pos.x = (-army_dir * ARMY_HALF_SEP) \
			+ (-army_dir * adding_band_index * STARTING_BAND_SEP) + rng.randf_range(-2, 2)
	creature.real_pos.z = z_pos
	parallax_engine.add_object_to_parallax_world(creature)
	adding_lane_index += 1

func fight(new_battlefronts, new_frontline_func):
	battlefronts = new_battlefronts
	frontline_func = new_frontline_func
	state = StateArmy.FIGHT

func get_state():
	return state
	
func _creature_death(): 
	dead_creatures += 1
	if dead_creatures >= defeat_threshold: 
		emit_signal("defeat")
		# TODO remove creatures from array
		# TODO Rout

func idle():
	state = StateArmy.IDLE
	for creature in get_all_creatures():
		creature.set_state(state, army_dir)

func get_frontline_at_lane(lane_num): 
	# TODO What happens when creatures are removed from the array?
	# TODO optimizie this
	return creature_lanes[lane_num][0]
	
