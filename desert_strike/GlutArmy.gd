extends "res://desert_strike/Army.gd"

func _ready(): 
	Creature = load("res://desert_strike/creature/Grubling.tscn")
	army_dir = Dir.LEFT
	initialize_army()
