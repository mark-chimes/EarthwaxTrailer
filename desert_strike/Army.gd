extends Node2D

signal defeat

# var creature = preload("res://desert_strike/creature/creature.tscn")
var Creature
onready var parallax_engine = get_parent().get_parent().get_node("ParallaxEngine")
onready var rng = RandomNumberGenerator.new()
var frontline_func = null

var creatures = []
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

var dead_creatures = 0
var defeat_threshold = 4
var army_dir = Dir.RIGHT

func initialize_army(): 
	rng.set_seed(hash("42069"))
	add_creature(3)
	add_creature(7)
	add_creature(11)
	add_creature(15)
	state = StateArmy.WALK
	for creature in creatures:
		creature.set_state(StateCreature.WALK, army_dir)

func _process(delta):
	match state:
		StateArmy.WALK:
			pass
		StateArmy.IDLE:
			pass
		StateArmy.FIGHT:
			for i in range(len(creatures)):
				var creature = creatures[i]
				if not creature.state == StateCreature.WALK:
					continue
				var enemy_pos = frontline_func.call_func(i+1)

				if abs(creature.real_pos.x - enemy_pos) < 2: 
					creature.set_state(StateCreature.FIGHT, army_dir)
					creature.connect("death", self, "_creature_death")
		StateArmy.DIE:
			pass

func get_pos():
	# TODO Optimize this
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

func add_creature(z_pos):
	var creature = Creature.instance()
	creature.set_rng(rng)
	creatures.append(creature)
	add_child(creature)
	creature.dir = army_dir
	creature.real_pos.x = (-army_dir * 20) + rng.randi_range(-10, 10)
	creature.real_pos.z = z_pos
	parallax_engine.add_object_to_parallax_world(creature)

func fight(new_frontline_func):
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
	for creature in creatures:
		creature.set_state(state, army_dir)

func get_frontline_at_lane(lane_num): 
	# TODO What happens when creatures are removed from the array?
	return creatures[lane_num-1].real_pos.x
	
