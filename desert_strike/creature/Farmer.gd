extends "res://desert_strike/creature/Creature.gd"
onready var FarmerCorpse = preload("res://desert_strike/creature/FarmerCorpse.tscn")

func _ready(): 
	sprite_dir = State.Dir.RIGHT
	mute = false
	time_between_attacks = rng.randf_range(1,3)
	melee_damage = rng.randi_range(5,10)
	ranged_damage = 0
	health = 10
	MAX_HEALTH = 10
	
func get_corpse(): 
	return FarmerCorpse
