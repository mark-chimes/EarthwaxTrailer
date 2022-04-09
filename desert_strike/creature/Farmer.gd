extends "res://desert_strike/creature/Creature.gd"


func _ready(): 
	sprite_dir = Dir.RIGHT
	mute = false
	time_between_attacks = 3
	melee_damage = rng.randi_range(2,10)
	ranged_damage = 0
