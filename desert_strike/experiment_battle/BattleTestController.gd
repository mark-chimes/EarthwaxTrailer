extends Node2D

var SquadAttacking = preload("res://desert_strike/army/SquadAttacking.gd")

# TODO this is more of a battle controller than an entity controller at this point
onready var parallax_engine = get_parent().get_node("ParallaxEngine")

func _ready():
	$BattleBoss.connect("attacker_defeat", self, "_human_defeat")
	$BattleBoss.connect("defender_defeat", self, "_glut_defeat")
	
	var human_squad_grid = $HumanSquadSpawner.start_army(parallax_engine)
	var glut_squad_grid = $GlutSquadSpawner.start_army(parallax_engine)
	
	var human_army = SquadAttacking.new()
	add_child(human_army)
	human_army.initialize_army(parallax_engine, -4, human_squad_grid, State.Dir.RIGHT)
	
	var glut_army = SquadAttacking.new()
	add_child(glut_army)
	glut_army.initialize_army(parallax_engine, 4, glut_squad_grid, State.Dir.LEFT)

	$BattleBoss.start_battle_between_armies(human_army, glut_army)

func human_army_from(army_grid): 
	pass
	#var human_army = HumanArmy.instance()
	

func _human_defeat(): 
	pass
	
func _glut_defeat(): 
	pass
