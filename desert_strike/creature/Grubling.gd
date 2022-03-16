extends "res://desert_strike/creature/Creature.gd"

func _ready(): 
	sprite_dir = Dir.LEFT
	mute = true
	health_bar.set_color(Color(1, 0, 255, 20))
