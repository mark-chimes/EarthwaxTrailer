extends "res://desert_strike/creature/Creature.gd"


func _ready(): 
	sprite_dir = State.Dir.RIGHT
	mute = false
	time_between_attacks = 3
	melee_damage = 10 #rng.randi_range(2,10)
	ranged_damage = 0
	health = 1000
	MAX_HEALTH = 1000
	
