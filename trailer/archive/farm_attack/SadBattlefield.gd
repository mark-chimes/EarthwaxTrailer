extends Node2D
signal end_scene

func _ready():
	$Commander.begin_idling()

var timer = 0
var switch = 0
var has_started = false

func _process(delta):
	if not has_started: 
		return
	timer += delta
	if timer >= 1 and switch == 1: 
		print("TIME 1")
		switch = 2
	if timer >= 2 and switch == 2:
		print("TIME 3")
		$Commander.begin_walking()
		$Commander.say("What a sad day", 3)
		switch = 6
	if timer >= 6 and switch == 6:
		print("TIME 9")
		$Commander.begin_walking()
		switch = 9
	if timer >= 9 and switch == 9:
		$Commander.say("A sad day indeed.", 3)
		print("TIME 23")
		switch = 15
	if timer >= 15 and switch == 15:
		print("TIME 18")
		emit_signal("end_scene")
		switch += 1
		
func start_battlefield_scene(): 
	timer = -1
	switch = 1
	has_started = true
