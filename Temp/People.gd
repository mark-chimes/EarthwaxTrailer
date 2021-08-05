extends Node2D

var timer = 0
var switch = 0
var has_started = false

func _ready(): 
	$Commander.visible = false
	$Spearman1.visible = false
	$Spearman2.visible = false	
	# TODO Farmer visibility

func _on_TimingsController_people_enter():
	has_started = true

func _process(delta):
	if not has_started: 
		return
	timer += delta
	if timer >= 0 and switch == 0:
		people_enter()
		switch = 2
	if timer >= 2 and switch == 2:
		$Farmer2.begin_walking()
		switch += 1
	if timer >= 3 and switch == 3:
		$Farmer1.begin_walking()
		switch = 10
	if timer >= 10 and switch == 10: 
		$Commander.go_left()
		$Commander.begin_walking()
		switch = 13
	if timer >= 13 and switch == 13: 
		$Spearman1.go_left()
		$Spearman2.go_left()
		$Spearman1.begin_walking()
		$Spearman2.begin_walking()
		
func people_enter():
	visible = true
	$Commander.visible = true
	$Commander.begin_walking()
	$Spearman1.begin_walking()
	$Spearman2.begin_walking()
	$Spearman1.visible = true
	$Spearman2.visible = true
