extends "res://desert_strike/creature/Creature.gd"

func _ready(): 
	sprite_dir = Dir.RIGHT
	mute = true
	time_between_attacks = 2
	damage = rng.randi_range(1,3) # For testing
	priority = 5
	is_ranged = true
