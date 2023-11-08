extends Node2D

var SquadAttacking = preload("res://desert_strike/army/SquadAttacking.gd")

# TODO this is more of a battle controller than an entity controller at this point
onready var parallax_engine = get_parent().get_node("ParallaxEngine")

func _ready():
	$BattleBoss.connect("attacker_defeat", self, "_human_defeat")
	$BattleBoss.connect("defender_defeat", self, "_glut_defeat")
	
	# TODO this doesn't seem right
	$HumanSquadSpawner.connect("add_creature_to_world", self, "add_creature_to_world")
	$GlutSquadSpawner.connect("add_creature_to_world", self, "add_creature_to_world")
	
	var human_squad = $HumanSquadSpawner.generate_starting_squad()
	var glut_squad = $GlutSquadSpawner.generate_starting_squad()
	
	var human_army = SquadAttacking.new()
	add_child(human_army)
	human_army.initialize_squad_from_list(-2, human_squad, State.Dir.RIGHT, 4)

	var glut_army = SquadAttacking.new()
	add_child(glut_army)
	glut_army.initialize_squad_from_list(2, glut_squad, State.Dir.LEFT, 4)

	var battlefront_pos = 0 # THIS WILL BE CALCULATED FROM MARCHING ARMIES
	
	human_army.connect("create_projectile", self, "add_projectile_to_world")
	human_army.connect("create_corpse", self, "add_corpse_to_world")
	glut_army.connect("create_projectile", self, "add_projectile_to_world")
	glut_army.connect("create_corpse", self, "add_corpse_to_world")
	
	$BattleBoss.start_battle_between_armies(human_army, glut_army, battlefront_pos)
	
	# SPAWNS LOTS OF EXTRA UNITS
	for x in range(10): 
		yield(get_tree().create_timer(1.0), "timeout")
		human_squad = $HumanSquadSpawner.generate_extra_squad()
		glut_squad = $GlutSquadSpawner.generate_extra_squad()
		human_army.add_new_creatures_from_list_and_position_them(human_squad)
		glut_army.add_new_creatures_from_list_and_position_them(glut_squad)


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
