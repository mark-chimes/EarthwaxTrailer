extends Node2D

# Called when the node enters the scene tree for the first time.
func _ready():
	$People._on_TimingsController_people_enter()


func _on_People_end_scene():
	$People.visible = false
