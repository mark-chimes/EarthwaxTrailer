extends Node2D

func _ready():
	start_scene()
	
func start_scene(): 
	visible = true
	$FarmsScene.start_farm_scene()
