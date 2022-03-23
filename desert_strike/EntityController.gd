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
	if not $ArmyHuman.has_creatures() or not $ArmyGlut.has_creatures(): 
		return
	
	if $ArmyHuman.get_state() == State.FIGHT or $ArmyHuman.get_state() == State.DIE\
			or $ArmyGlut.get_state() == State.FIGHT or $ArmyGlut.get_state() == State.DIE:
		return
	
	if abs($ArmyHuman.get_pos() - $ArmyGlut.get_pos()) < BATTLE_SEP:
		var battlefront_base = ($ArmyHuman.get_pos() + $ArmyGlut.get_pos())/2
		var battlefronts = []
		# TODO RANDOM
		for i in range(0,NUM_LANES): 
			var offset = rng.randf_range(-0.2, 0.2)
			battlefronts.append(battlefront_base + offset)
		$ArmyHuman.fight(battlefronts, $ArmyGlut.army_grid)
		$ArmyGlut.fight(battlefronts, $ArmyHuman.army_grid)
		$ArmyHuman.connect("attack", $ArmyGlut, "_on_get_attacked")
		$ArmyGlut.connect("attack", $ArmyHuman, "_on_get_attacked")

func _human_defeat():
	$ArmyGlut.idle()
