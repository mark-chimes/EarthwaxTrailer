extends "res://desert_strike/creature/Creature.gd"

func _ready(): 
	sprite_dir = Dir.RIGHT
	mute = false
	time_between_attacks = 5
	damage = 5
