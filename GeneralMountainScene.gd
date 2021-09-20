extends Node2D

# TODO Better variables here
var is_ending_farm_scene = false
var is_ending_sad_battlefield = false

# Called when the node enters the scene tree for the first time.
func _ready():
	$TimingsController.visible = true
	$FarmsScene.visible = false
	$SadBattlefield.visible = false
	$TimingsController.start_scene()

func _on_People_end_scene():
	print("PEOPLE END SCENE")
	$TimingsController.visible = false
	$FarmsScene.visible = true
	$FarmsScene.start_farm_scene()

func _on_People_start_fading():
	$fade.start_fading()

func _on_FarmsScene_end_scene():
	is_ending_farm_scene = true
	$fade.start_fading()
	
func _on_fade_half_fade():
	if is_ending_farm_scene:
		$FarmsScene.visible = false
	if is_ending_sad_battlefield: 
		$SadBattlefield.visible = false
		#$TimingsController.visible = true
		#$TimingsController.start_scene()
		#$SadBattlefield.visible = true
		#$SadBattlefield.start_battlefield_scene()

func _on_SadBattlefield_end_scene():
	is_ending_sad_battlefield = true
	$fade.start_fading()
