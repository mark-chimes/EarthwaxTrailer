extends "res://desert_strike/creature/Creature.gd"

onready var Arrow =  preload("res://desert_strike/Arrow.tscn")
onready var ArcherCorpse = preload("res://desert_strike/creature/ArcherCorpse.tscn")

signal fire_projectile(this, projectile)

func _ready(): 
	sprite_dir = State.Dir.RIGHT
	time_between_attacks = 3 # TODO should be different for melee and range
	ranged_damage = 10 # rng.randi_range(6,10)
	melee_damage = rng.randi_range(1,2)
	is_ranged = true
	min_attack_range = 0
	attack_range = 10
	mute = true
	health = 10
	MAX_HEALTH = 10

func fire_ranged_projectile(): 
	var projectile = Arrow.instance()
	projectile.ranged_target_band = ranged_target_band
	projectile.ranged_target_lane = ranged_target_lane
	projectile.ranged_damage = ranged_damage
	emit_signal("fire_projectile", self, projectile)

func get_corpse(): 
	return ArcherCorpse
