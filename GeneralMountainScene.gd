extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready():
	$TimingsController.visible = true
	$FarmsScene.visible = false

func _on_People_end_scene():
	print("PEOPLE END SCENE")
	$TimingsController.visible = false

	$FarmsScene.visible = true
	$FarmsScene.start_farm_scene()

func _on_People_start_fading():
	$fade.start_fading()

func _on_FarmsScene_end_scene():
	$fade.start_fading()
