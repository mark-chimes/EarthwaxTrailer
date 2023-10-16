extends Node2D

func _ready():
	pass # Replace with function body.

func set_income(new_income): 
	$Label.text = str(new_income)
