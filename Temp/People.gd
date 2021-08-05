extends Node2D

func _ready(): 
	$Commander.visible = false
	$Spearman1.visible = false
	$Spearman2.visible = false	
	
func _on_Rabbits_people_enter():
	visible = true
	$Commander.visible = true
	$Commander.begin_walking()
	$Spearman1.begin_walking()
	$Spearman2.begin_walking()
	$Spearman1.visible = true
	$Spearman2.visible = true
