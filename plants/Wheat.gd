extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_Area1_area_entered(area):
#	return
	if area.name == "GremlinArea":
		$Quarter1.frame = 1

func _on_Area2_area_entered(area):
#	return
	if area.name == "GremlinArea":
		$Quarter2.frame = 1

func _on_Area3_area_entered(area):
#	return
	if area.name == "GremlinArea":
		$Quarter3.frame = 1

func _on_Area4_area_entered(area):
#	return
	if area.name == "GremlinArea":
		$Quarter4.frame = 1

func _on_Area1_area_exited(area):
#	return
	if area.name == "GremlinArea":
		$Quarter1.frame = 0

func _on_Area2_area_exited(area):
#	return
	if area.name == "GremlinArea":
		$Quarter2.frame = 0

func _on_Area3_area_exited(area):
#	return
	if area.name == "GremlinArea":
		$Quarter3.frame = 0

func _on_Area4_area_exited(area):
#	return
	if area.name == "GremlinArea":
		$Quarter4.frame = 0
