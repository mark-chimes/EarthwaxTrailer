extends Node2D

# TODO this is more of a battle controller than an entity controller at this point

func _ready():
	$BattlefieldAdjudicator.connect("attacker_defeat", self, "_human_defeat")
	$BattlefieldAdjudicator.connect("defender_defeat", self, "_glut_defeat")
	
	$HumanWarbandAttacking.set_army_start_offset(-4)
	$GlutWarbandAttacking.set_army_start_offset(4)
	$HumanWarbandAttacking.start_army()
	$GlutWarbandAttacking.start_army()
	$BattlefieldAdjudicator.start_battle_between_armies($HumanWarbandAttacking, $GlutWarbandAttacking)

func _human_defeat(): 
	pass
	
func _glut_defeat(): 
	pass
