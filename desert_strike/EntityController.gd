extends Node2D

enum State {
	WALK,
	FIGHT,
	IDLE,
	DIE,
}

const BATTLE_SEP = 10
const NUM_LANES = 4
onready var rng = RandomNumberGenerator.new()

func _ready():
	$ArmyHuman.connect("defeat", self, "_human_defeat")
	rng.randomize()

func _process(delta):
	if abs($ArmyHuman.get_pos() - $ArmyGlut.get_pos()) < BATTLE_SEP && $ArmyHuman.get_state() != State.FIGHT && $ArmyHuman.get_state() != State.DIE:
		var battlefront_base = ($ArmyHuman.get_pos() + $ArmyGlut.get_pos())/2
		var battlefronts = []
		# TODO RANDOM
		for i in range(0,NUM_LANES): 
			var offset = rng.randf_range(-0.2, 0.2)
			battlefronts.append(battlefront_base + offset)
		$ArmyHuman.fight(battlefronts, funcref($ArmyGlut, 'get_frontline_at_lane'))
		$ArmyGlut.fight(battlefronts, funcref($ArmyHuman, 'get_frontline_at_lane'))

func _human_defeat():
	$ArmyGlut.idle()
