extends Node2D

signal end_scene
signal start_fading

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
		switch = 3
	if timer >= 3 and switch == 3:
		$Farmer2.begin_walking()
		switch += 1
	if timer >= 4 and switch == 4: 
		$Farmer1.begin_walking()
		$Commander.say("Ah, these fertile lands will be perfect for our new farms!", 4)
		switch = 9
	if timer >= 9 and switch == 9: 
		$Commander.say("Farmers, get to work!", 3)
		switch = 13
	if timer >= 13 and switch == 13: 
		$Commander.go_left()
		$Commander.begin_walking()
		$Spearman2.go_left()
		$Spearman2.begin_walking()
		switch = 14
	if timer >= 14 and switch == 14: 
		$Spearman1.go_left()
		$Spearman1.begin_walking()
		switch = 16
	if timer >= 16 and switch == 16:
		emit_signal("start_fading")
		switch = 17
	if timer >= 17 and switch == 17: 
		switch = 18
		emit_signal("end_scene")
		
func people_enter():
	visible = true
	$Commander.visible = true
	$Commander.begin_walking()
	$Spearman1.begin_walking()
	$Spearman2.begin_walking()
	$Spearman1.visible = true
	$Spearman2.visible = true
