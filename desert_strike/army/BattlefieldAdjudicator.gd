extends Node

signal attacker_defeat
signal defender_defeat

# Oversees battles - alternative name: Battlefield / Adjudicator / Battlemaster

var State = preload("res://desert_strike/State.gd")

const BATTLE_SEP = 10
const NUM_LANES = 4
onready var rng = RandomNumberGenerator.new()

var attacker = null
var defender = null

onready var is_initialized = false

func start_battle_between_armies(attacking_warband, defending_warband): 
	rng.randomize()
	attacker = attacking_warband
	defender = defending_warband
	attacker.connect("defeat", self, "_attacker_defeat")
	defender.connect("defeat", self, "_defender_defeat")
	is_initialized = true

func _process(delta):
	if not is_initialized: 
		return
	continue_battle()

func continue_battle():
	if attacker.get_state() == State.Army.BATTLE or attacker.get_state() == State.Army.DIE\
			or defender.get_state() == State.Army.BATTLE or defender.get_state() == State.Army.DIE:
		return
	
	if abs(attacker.get_pos() - defender.get_pos()) < BATTLE_SEP:
		var battlefront_base = (attacker.get_pos() + defender.get_pos())/2
		var battlefronts = []
		# TODO RANDOM
		for i in range(0,NUM_LANES): 
			var offset = rng.randf_range(-0.2, 0.2)
			battlefronts.append(battlefront_base + offset)
		
		attacker.battle(battlefronts, defender.army_grid)
		defender.battle(battlefronts, attacker.army_grid)
		attacker.connect("front_line_ready", defender, "_on_front_line_ready")
		defender.connect("front_line_ready", attacker, "_on_front_line_ready")
		attacker.connect("creature_death", defender, "_on_enemy_creature_death")
		defender.connect("creature_death", attacker, "_on_enemy_creature_death")
		attacker.connect("attack", defender, "_on_get_attacked")
		defender.connect("attack", attacker, "_on_get_attacked")
		attacker.connect("projectile_attack", defender, "_on_enemy_projectile_attack")

	
func _attacker_defeat():
	# TODO Defeat actions
	disconnect_signals()
	emit_signal("attacker_defeat")
	
func _defender_defeat():
	# TODO Defeat actions
	disconnect_signals()
	emit_signal("defender_defeat")

func disconnect_signals(): 
	attacker.disconnect("front_line_ready", defender, "_on_front_line_ready")
	defender.disconnect("front_line_ready", attacker, "_on_front_line_ready")
	attacker.disconnect("creature_death", defender, "_on_enemy_creature_death")
	defender.disconnect("creature_death", attacker, "_on_enemy_creature_death")
	attacker.disconnect("attack", defender, "_on_get_attacked")
	defender.disconnect("attack", attacker, "_on_get_attacked")
	attacker.disconnect("projectile_attack", defender, "_on_enemy_projectile_attack")
	defender.disconnect("projectile_attack", attacker, "_on_enemy_projectile_attack")
