extends Node2D

var SquadAttacking = preload("res://desert_strike/army/SquadAttacking.gd")

# TODO this is more of a battle controller than an entity controller at this point
onready var parallax_engine = get_parent().get_node("ParallaxEngine")
enum TestType {
	MARCH,
	ATTACK,
	MARCH_AND_DEFEND
}

export(TestType) var test_type = TestType.MARCH
export var seconds_between_spawns = 3

func _ready():
	if test_type == TestType.MARCH:
		march_test()
	elif test_type == TestType.ATTACK:
		attack_test()
	elif test_type == TestType.MARCH_AND_DEFEND:
		march_and_defend_test()

var human_march
var glut_march_or_defense

func march_test(): 
	var human_squad_march = $HumanMarchSquadSpawner.generate_squad()
	var glut_squad_march = $GlutMarchSquadSpawner.generate_squad()
	for creature in human_squad_march.get_all_creatures(): 
		add_creature_to_world(creature)
	for creature in glut_squad_march.get_all_creatures(): 
		add_creature_to_world(creature)
		
	human_march = SquadMarching.new()
	human_march.initialize_army_from_grid(human_squad_march, State.Dir.RIGHT)
	glut_march_or_defense = SquadMarching.new()
	glut_march_or_defense.initialize_army_from_grid(glut_squad_march, State.Dir.LEFT)

func march_and_defend_test(): 
	var human_squad_march = $HumanMarchSquadSpawner.generate_squad()
	var glut_squad_defend = $GlutDefendSquadSpawner.generate_squad()
	for creature in human_squad_march.get_all_creatures(): 
		add_creature_to_world(creature)
	for creature in glut_squad_defend.get_all_creatures(): 
		add_creature_to_world(creature)
		
	human_march = SquadMarching.new()
	human_march.initialize_army_from_grid(human_squad_march, State.Dir.RIGHT)
	glut_march_or_defense = SquadDefending.new()
	glut_march_or_defense.initialize_army_from_grid(glut_squad_defend, State.Dir.LEFT)

const BATTLE_SEP = 10
const NUM_LANES = 4
var battlefront_base = -100
var has_started_attacking = false # TODO do this better
func _process(delta): 
	if (test_type == TestType.MARCH or 
			test_type == TestType.MARCH_AND_DEFEND
			and not has_started_attacking): 
		var human_front = human_march.get_front_of_squad()
		var glut_front = glut_march_or_defense.get_front_of_squad()
		if abs(human_front - glut_front) < BATTLE_SEP:
			battlefront_base = (human_front + glut_front)/2
			attack_after_march()
			has_started_attacking = true
	
func attack_after_march():
	# TODO This should be neatly packaged
	var human_squad = human_march.army_grid.get_all_creatures()
	# human_march.queue_free()
	var glut_squad = glut_march_or_defense.army_grid.get_all_creatures()
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
	var human_squad = $HumanBattleSquadSpawner.generate_squad().get_all_creatures()
	var glut_squad = $GlutBattleSquadSpawner.generate_squad().get_all_creatures()
	for creature in human_squad: 
		add_creature_to_world(creature)
	for creature in glut_squad: 
		add_creature_to_world(creature)
		
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
		yield(get_tree().create_timer(seconds_between_spawns), "timeout")

		human_squad = $HumanBattleSquadSpawner.generate_squad().get_all_creatures()
		glut_squad = $GlutBattleSquadSpawner.generate_squad().get_all_creatures()
		for creature in human_squad: 
			add_creature_to_world(creature)
		for creature in glut_squad: 
			add_creature_to_world(creature)
			
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
