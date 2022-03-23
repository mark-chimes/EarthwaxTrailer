extends Node2D

signal defeat
signal attack(lane, damage)

var ArmyGrid = preload("res://desert_strike/ArmyGrid.gd")

# var creature = preload("res://desert_strike/creature/creature.tscn")
var Creature
onready var parallax_engine = get_parent().get_parent().get_node("ParallaxEngine")
onready var rng = RandomNumberGenerator.new()
var frontline_func = null
var battlefronts = []

onready var army_grid = ArmyGrid.new()

# TODO Special parallax converter subobject for grid army positions to real positions. 

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

func initialize_army(): 
	rng.set_seed(hash("42069"))
	army_grid.initialize(NUM_LANES)
	for i in range(0, NUM_LANES + 12):
		add_creature()
	state = StateArmy.WALK
	for creature in army_grid.get_all_creatures():
		creature.set_state(StateCreature.WALK, army_dir)

func _process(delta):
	match state:
		StateArmy.WALK:
			pass
		StateArmy.IDLE:
			pass
		StateArmy.FIGHT:
			for lane_index in range(NUM_LANES): 
				# var lane = army_grid.get_lane(lane_index)
				var lane_offset = FIGHT_SEP + lane_index*1.0/10
				var front_enemy = frontline_func.call_func(lane_index)
				
				for band_index in range(army_grid.get_lane_length(lane_index)):
					var creature = army_grid.get_creature_band_lane(band_index, lane_index)
					
					if not creature.state == StateCreature.WALK:
						continue
						
					if band_index == 0: 
						# TODO - absolute grid army positions
						if abs(creature.real_pos.x - (battlefronts[lane_index] - (army_dir * lane_offset))) < END_POS_DELTA: 
							creature.connect("attack", self, "_on_creature_attack")
							creature.set_state(StateCreature.FIGHT, army_dir)
							creature.connect("death", self, "_creature_death")
					else: # Not a frontline unit 
						var goal_x = battlefronts[lane_index] - (army_dir * (lane_offset + band_index * BAND_SEP))
						
						if abs(creature.real_pos.x - goal_x) < END_POS_DELTA: 
							creature.set_state(StateCreature.IDLE, army_dir)
							
		StateArmy.DIE:
			pass

func _on_creature_attack(attacker): 
	# TODO different behaviour for melee vs ranged vs reach etc.
	# TODO When you have melee, reach, range need a way for attackers to know if there is a target
	# TODO need a way to know how to pick a good target, etc.	
	
	# The other army will know to attack the frontline of its lane
	emit_signal("attack", attacker.lane, attacker.damage)
	
func _on_get_attacked(lane, damage): 
	get_frontline_at_lane(lane).take_damage(damage)
		
func get_pos():
	# TODO Optimize this
	# TODO only needs the frontline
	var creatures = army_grid.get_all_creatures()
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
	creature.set_rng(rng)
	army_grid.add_creature(creature)
	var z_pos = (creature.lane * DISTANCE_BETWEEN_LANES) + 3 
	creature.real_pos.z = z_pos
	add_child(creature)
	creature.dir = army_dir
	creature.real_pos.x = (-army_dir * ARMY_HALF_SEP) \
			+ (-army_dir * creature.band * STARTING_BAND_SEP) + rng.randf_range(-2, 2)
	parallax_engine.add_object_to_parallax_world(creature)
	

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
	for creature in army_grid.get_all_creatures():
		creature.set_state(state, army_dir)

func get_frontline_at_lane(lane_num): 
	# TODO What happens when creatures are removed from the array?
	# TODO optimize this
	return army_grid.get_creature_band_lane(0, lane_num)
	
