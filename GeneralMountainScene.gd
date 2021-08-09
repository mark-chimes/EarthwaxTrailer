extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready():
	$TimingsController.visible = true
	$FarmsScene.visible = false

func _on_People_end_scene():
	$TimingsController.visible = false
	$FarmsScene.visible = true
