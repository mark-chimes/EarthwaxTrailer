extends "res://desert_strike/creature/Creature.gd"

onready var Arrow =  preload("res://desert_strike/Arrow.tscn")

signal fire_projectile(archer_pos, target_band, target_lane, projectile)

func _ready(): 
	sprite_dir = State.Dir.RIGHT
	time_between_attacks = 3 # TODO should be different for melee and range
	ranged_damage = rng.randi_range(6,10)
	melee_damage = rng.randi_range(1,2)
	is_ranged = true
	attack_range = 30
	mute = true
	health = 1000
	MAX_HEALTH = 1000

func fire_ranged_projectile(): 
	var projectile = Arrow.instance()
	emit_signal("fire_projectile", real_pos, ranged_target_band, ranged_target_lane, projectile)

