extends Node2D

func _ready():
	#visible = false
	$FarmsScene.start_farm_scene()
	
func start_scene(): 
	visible = true
	
	# $SadBattlefield.start_battlefield_scene()
