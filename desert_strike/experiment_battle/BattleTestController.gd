extends Node2D

var WarbandAttacking = preload("res://desert_strike/army/WarbandAttacking.gd")

# TODO this is more of a battle controller than an entity controller at this point
onready var parallax_engine = get_parent().get_node("ParallaxEngine")

func _ready():
	$BattlefieldAdjudicator.connect("attacker_defeat", self, "_human_defeat")
	$BattlefieldAdjudicator.connect("defender_defeat", self, "_glut_defeat")
	
	var human_warband_grid = $HumanWarbandSpawner.start_army(parallax_engine)
	var glut_warband_grid = $GlutWarbandSpawner.start_army(parallax_engine)
	
	var human_army = WarbandAttacking.new()
	add_child(human_army)
	human_army.initialize_army(parallax_engine, -4, human_warband_grid, State.Dir.RIGHT)
	
	var glut_army = WarbandAttacking.new()
	add_child(glut_army)
	glut_army.initialize_army(parallax_engine, 4, glut_warband_grid, State.Dir.LEFT)

	$BattlefieldAdjudicator.start_battle_between_armies(human_army, glut_army)

func human_army_from(army_grid): 
	pass
	#var human_army = HumanArmy.instance()
	

func _human_defeat(): 
	pass
	
func _glut_defeat(): 
	pass
