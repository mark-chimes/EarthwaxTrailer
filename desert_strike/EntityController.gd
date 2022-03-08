extends Node2D

func _process(delta):
	if abs($ArmyHuman.get_pos() - $ArmyGlut.get_pos()) <= 2:
		$ArmyHuman.fight()
		$ArmyGlut.fight()
