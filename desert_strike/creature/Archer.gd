extends "res://desert_strike/creature/Creature.gd"

func _ready(): 
	sprite_dir = Dir.RIGHT
	mute = true
	time_between_attacks = 3 # TODO should be different for melee and range
	ranged_damage = rng.randi_range(2,4)
	melee_damage = rng.randi_range(1,2)
	is_ranged = true
	attack_range = 3
