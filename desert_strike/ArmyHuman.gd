extends "res://desert_strike/Army.gd"

func _ready(): 
	Creature = load("res://desert_strike/creature/Farmer.tscn")
	army_dir = Dir.RIGHT
	initialize_army()
