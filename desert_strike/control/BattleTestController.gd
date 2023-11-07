extends Node2D

# TODO this is more of a battle controller than an entity controller at this point
var State = preload("res://desert_strike/State.gd")

const BATTLE_SEP = 10
const NUM_LANES = 4
onready var rng = RandomNumberGenerator.new()

onready var parallax_engine = get_parent().get_node("ParallaxEngine")

func _ready():
	$HumanWarbandAttacking.connect("defeat", self, "_human_defeat")
	$GlutWarbandAttacking.connect("defeat", self, "_glut_defeat")
	
	$HumanWarbandAttacking.set_army_start_offset(-30)
	$GlutWarbandAttacking.set_army_start_offset(10)
	$HumanWarbandAttacking.start_army()
	$GlutWarbandAttacking.start_army()
	
	rng.randomize()

func _process(delta):
	battle_start()


func battle_start():
	if $HumanWarbandAttacking.get_state() == State.Army.BATTLE or $HumanWarbandAttacking.get_state() == State.Army.DIE\
			or $GlutWarbandAttacking.get_state() == State.Army.BATTLE or $GlutWarbandAttacking.get_state() == State.Army.DIE:
		return
	
	if abs($HumanWarbandAttacking.get_pos() - $GlutWarbandAttacking.get_pos()) < BATTLE_SEP:
		var battlefront_base = ($HumanWarbandAttacking.get_pos() + $GlutWarbandAttacking.get_pos())/2
		var battlefronts = []
		# TODO RANDOM
		for i in range(0,NUM_LANES): 
			var offset = rng.randf_range(-0.2, 0.2)
			battlefronts.append(battlefront_base + offset)
		
		$HumanWarbandAttacking.battle(battlefronts, $GlutWarbandAttacking.army_grid)
		$GlutWarbandAttacking.battle(battlefronts, $HumanWarbandAttacking.army_grid)
		$HumanWarbandAttacking.connect("front_line_ready", $GlutWarbandAttacking, "_on_front_line_ready")
		$GlutWarbandAttacking.connect("front_line_ready", $HumanWarbandAttacking, "_on_front_line_ready")
		$HumanWarbandAttacking.connect("creature_death", $GlutWarbandAttacking, "_on_enemy_creature_death")
		$GlutWarbandAttacking.connect("creature_death", $HumanWarbandAttacking, "_on_enemy_creature_death")
		$HumanWarbandAttacking.connect("attack", $GlutWarbandAttacking, "_on_get_attacked")
		$GlutWarbandAttacking.connect("attack", $HumanWarbandAttacking, "_on_get_attacked")
		$HumanWarbandAttacking.connect("projectile_attack", $GlutWarbandAttacking, "_on_enemy_projectile_attack")

	
func _human_defeat():
	# TODO Defeat actions
	disconnect_signals()
	
func _glut_defeat():
	# TODO Defeat actions
	disconnect_signals()

func disconnect_signals(): 
	$HumanWarbandAttacking.disconnect("front_line_ready", $GlutWarbandAttacking, "_on_front_line_ready")
	$GlutWarbandAttacking.disconnect("front_line_ready", $HumanWarbandAttacking, "_on_front_line_ready")
	$HumanWarbandAttacking.disconnect("creature_death", $GlutWarbandAttacking, "_on_enemy_creature_death")
	$GlutWarbandAttacking.disconnect("creature_death", $HumanWarbandAttacking, "_on_enemy_creature_death")
	$HumanWarbandAttacking.disconnect("attack", $GlutWarbandAttacking, "_on_get_attacked")
	$GlutWarbandAttacking.disconnect("attack", $HumanWarbandAttacking, "_on_get_attacked")
	$HumanWarbandAttacking.disconnect("projectile_attack", $GlutWarbandAttacking, "_on_enemy_projectile_attack")
	$GlutWarbandAttacking.disconnect("projectile_attack", $HumanWarbandAttacking, "_on_enemy_projectile_attack")
	$HumanWarbandAttacking.disconnect("many_deaths", self, "_on_many_human_deaths")
	$GlutWarbandAttacking.disconnect("many_deaths", self, "_on_many_glut_deaths")
