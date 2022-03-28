extends "res://experiment/3d_pixel/creature3d/Creature.gd"


func _ready(): 
	sprite_dir = Dir.RIGHT
	mute = false
	time_between_attacks = 10
	melee_damage = rng.randi_range(2,10)
	ranged_damage = 0
	priority = 10
