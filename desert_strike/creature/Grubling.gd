extends "res://desert_strike/creature/Creature.gd"

func _ready(): 
	sprite_dir = Dir.LEFT
	mute = true
	var purple = Color8(122, 0, 180, 75)
	health_bar.set_color(purple)
	time_between_attacks = 2
	melee_damage = rng.randi_range(3,7)
	ranged_damage = 0
	priority = 10
