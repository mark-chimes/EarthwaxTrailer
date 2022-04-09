extends Node2D

# TODO this is more of a battle controller than an entity controller at this point

enum StateArmy {
	MARCH,
	BATTLE,
	IDLE,
	DIE,
}

const BATTLE_SEP = 10
const NUM_LANES = 4
onready var rng = RandomNumberGenerator.new()

const TIME_BETWEEN_WAVES = 200000
var wave_timer = 0 

func _ready():
	$ArmyHuman.connect("defeat", self, "_human_defeat")
	rng.randomize()

func _process(delta):
	if not $ArmyHuman.has_creatures() or not $ArmyGlut.has_creatures(): 
		return
	
	# TODO Waves for already-defeated armies.
	if wave_timer >= TIME_BETWEEN_WAVES: 
		# new wave
		$ArmyHuman.spawn_new_wave()
		$ArmyGlut.spawn_new_wave()
		wave_timer = 0
	else: 
		wave_timer += delta
	
	if $ArmyHuman.get_state() == StateArmy.BATTLE or $ArmyHuman.get_state() == StateArmy.DIE\
			or $ArmyGlut.get_state() == StateArmy.BATTLE or $ArmyGlut.get_state() == StateArmy.DIE:
		return
	
	
	if abs($ArmyHuman.get_pos() - $ArmyGlut.get_pos()) < BATTLE_SEP:
		var battlefront_base = ($ArmyHuman.get_pos() + $ArmyGlut.get_pos())/2
		var battlefronts = []
		# TODO RANDOM
		for i in range(0,NUM_LANES): 
			var offset = rng.randf_range(-0.2, 0.2)
			battlefronts.append(battlefront_base + offset)
		$ArmyHuman.battle(battlefronts, $ArmyGlut.army_grid)
		$ArmyGlut.battle(battlefronts, $ArmyHuman.army_grid)
		$ArmyHuman.connect("front_line_ready", $ArmyGlut, "_on_front_line_ready")
		$ArmyGlut.connect("front_line_ready", $ArmyHuman, "_on_front_line_ready")
		$ArmyHuman.connect("creature_death", $ArmyGlut, "_on_enemy_creature_death")
		$ArmyGlut.connect("creature_death", $ArmyHuman, "_on_enemy_creature_death")
		$ArmyHuman.connect("attack", $ArmyGlut, "_on_get_attacked")
		$ArmyGlut.connect("attack", $ArmyHuman, "_on_get_attacked")

func _human_defeat():
	$ArmyGlut.idle()
