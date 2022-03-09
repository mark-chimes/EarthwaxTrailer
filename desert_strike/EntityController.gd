extends Node2D

enum State {
	WALK,
	FIGHT,
	IDLE,
	DIE,
}

func _ready():
	$ArmyHuman.connect("defeat", self, "_human_defeat")

func _process(delta):
	if abs($ArmyHuman.get_pos() - $ArmyGlut.get_pos()) <= 2 && $ArmyHuman.get_state() != State.FIGHT && $ArmyHuman.get_state() != State.DIE:
		$ArmyHuman.fight(funcref($ArmyGlut, 'get_frontline_at_lane'))
		$ArmyGlut.fight(funcref($ArmyHuman, 'get_frontline_at_lane'))

func _human_defeat():
	$ArmyGlut.idle()
