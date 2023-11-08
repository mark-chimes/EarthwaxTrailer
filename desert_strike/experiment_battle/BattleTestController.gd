extends Node2D

var SquadAttacking = preload("res://desert_strike/army/SquadAttacking.gd")

# TODO this is more of a battle controller than an entity controller at this point
onready var parallax_engine = get_parent().get_node("ParallaxEngine")
var is_march_test = false

func _ready():
	# TODO this doesn't seem right
	$HumanSquadSpawner.connect("add_creature_to_world", self, "add_creature_to_world")
	$GlutSquadSpawner.connect("add_creature_to_world", self, "add_creature_to_world")
	march_test()

var human_march
var glut_march

func march_test(): 
	var human_squad_march = $HumanSquadSpawner.generate_starting_squad_grid_for_marching()
	var glut_squad_march = $GlutSquadSpawner.generate_starting_squad_grid_for_marching()

	human_march = SquadMarching.new()
	human_march.initialize_army_from_grid(human_squad_march, State.Dir.RIGHT)
	glut_march = SquadMarching.new()
	glut_march.initialize_army_from_grid(glut_squad_march, State.Dir.LEFT)
	is_march_test = true

const BATTLE_SEP = 10
const NUM_LANES = 4
var battlefront_base = -100
var has_started_attacking = false # TODO do this better
func _process(delta): 
	if is_march_test and not has_started_attacking: 
		var human_front = human_march.get_front_of_squad()
		var glut_front = glut_march.get_front_of_squad()
		if abs(human_front - glut_front) < BATTLE_SEP:
			battlefront_base = (human_front + glut_front)/2
			attack_after_march()
			has_started_attacking = true
	
func attack_after_march():
	# TODO This should be neatly packaged
	var human_squad = human_march.army_grid.get_all_creatures()
	# human_march.queue_free()
	var glut_squad = glut_march.army_grid.get_all_creatures()
	# glut_march.queue_free()
	
	var attacker = SquadAttacking.new()
	add_child(attacker) # TODO Hacky because of timers
	attacker.initialize_squad_from_list(-2, human_squad, State.Dir.RIGHT, 4)

	var defender = SquadAttacking.new()
	add_child(defender) # TODO Hacky because of timers
	defender.initialize_squad_from_list(2, glut_squad, State.Dir.LEFT, 4)

	var battlefront_pos = battlefront_base
	
	attacker.connect("create_projectile", self, "add_projectile_to_world")
	attacker.connect("create_corpse", self, "add_corpse_to_world")
	defender.connect("create_projectile", self, "add_projectile_to_world")
	defender.connect("create_corpse", self, "add_corpse_to_world")
	$BattleBoss.start_battle_between_armies(attacker, defender, battlefront_pos)
	$BattleBoss.connect("attacker_defeat", self, "_human_defeat")
	$BattleBoss.connect("defender_defeat", self, "_glut_defeat")


func attack_test():
	var human_squad = $HumanSquadSpawner.generate_starting_squad()
	var glut_squad = $GlutSquadSpawner.generate_starting_squad()
	
	var attacker = SquadAttacking.new()
	add_child(attacker) # TODO Hacky because of timers
	attacker.initialize_squad_from_list(-2, human_squad, State.Dir.RIGHT, 4)

	var defender = SquadAttacking.new()
	add_child(defender) # TODO Hacky because of timers
	defender.initialize_squad_from_list(2, glut_squad, State.Dir.LEFT, 4)

	var battlefront_pos = 0 # THIS WILL BE CALCULATED FROM MARCHING ARMIES
	
	attacker.connect("create_projectile", self, "add_projectile_to_world")
	attacker.connect("create_corpse", self, "add_corpse_to_world")
	defender.connect("create_projectile", self, "add_projectile_to_world")
	defender.connect("create_corpse", self, "add_corpse_to_world")
	$BattleBoss.start_battle_between_armies(attacker, defender, battlefront_pos)
	$BattleBoss.connect("attacker_defeat", self, "_human_defeat")
	$BattleBoss.connect("defender_defeat", self, "_glut_defeat")
	
	# SPAWNS LOTS OF EXTRA UNITS
	for x in range(10): 
		yield(get_tree().create_timer(1.0), "timeout")

		human_squad = $HumanSquadSpawner.generate_extra_squad()
		glut_squad = $GlutSquadSpawner.generate_extra_squad()
		
		# TODO I am unsure of where the reinforcement code should happen
		attacker.reinforce_squad(human_squad)
		defender.reinforce_squad(glut_squad)

func add_projectile_to_world(projectile): 
	# projectile.parallax_engine = parallax_engine
	add_child(projectile)
	parallax_engine.add_object_to_parallax_world(projectile)
	projectile.connect("disappear", parallax_engine, "_on_projectile_disappear")
		
func add_creature_to_world(creature): 
	creature.parallax_engine = parallax_engine
	add_child(creature)
	parallax_engine.add_object_to_parallax_world(creature)
	creature.connect("disappear", parallax_engine, "_on_object_disappear")

func add_corpse_to_world(corpse): 
	add_child(corpse)
	parallax_engine.add_object_to_parallax_world(corpse)
	corpse.connect("disappear", parallax_engine, "_on_object_disappear")

func human_army_from(army_grid): 
	pass
	
func _human_defeat(): 
	pass
	
func _glut_defeat(): 
	pass
