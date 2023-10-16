extends Node2D

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func set_income(new_income): 
	$Label.text = str(new_income)
