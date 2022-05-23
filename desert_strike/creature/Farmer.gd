extends "res://desert_strike/creature/Creature.gd"
onready var FarmerCorpse = preload("res://desert_strike/creature/FarmerCorpse.tscn")

func _ready(): 
	sprite_dir = State.Dir.RIGHT
	mute = false
	time_between_attacks = rng.randf_range(2,4)
	melee_damage = 1 # rng.randi_range(2,7)
	ranged_damage = 0
	health = 100
	MAX_HEALTH = 100
	
func get_corpse(): 
	return FarmerCorpse
