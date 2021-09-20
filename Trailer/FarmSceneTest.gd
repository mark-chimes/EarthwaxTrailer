extends Node2D

func _ready():
	#visible = false
	start_scene()
	
func start_scene(): 
	visible = true
	$SadBattlefield.start_battlefield_scene()
