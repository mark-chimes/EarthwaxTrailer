extends "res://desert_strike/creature/Creature.gd"
onready var GrublingCorpse = preload("res://desert_strike/creature/GrublingCorpse.tscn")

func _ready(): 
	sprite_dir = State.Dir.LEFT
	var purple = Color8(122, 0, 180, 75)
	health_bar.set_color(purple)
	time_between_attacks = rng.randf_range(1.0,2.5)
	melee_damage = rng.randi_range(20,30)
	ranged_damage = 0
	var light_purple = Color8(180, 120, 220, 255)
	speech_box.set_font_color(light_purple)
	mute = true
	
func get_corpse(): 
	return GrublingCorpse
