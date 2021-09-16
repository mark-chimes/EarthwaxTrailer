extends Node2D
signal end_scene

var timer = 0
var switch = 0
var has_started = false

func _process(delta):
	if not has_started: 
		return
	timer += delta
	if timer >= 1 and switch == 1:
		$Gremlins.start_gremlins()
		switch = 4
	if timer >= 4 and switch == 4: 
		$FarmerGremlins.huh()
		switch = 5
	if timer >= 5 and switch == 5: 
		$FarmerGremlins.point()
		switch = 7.9
	if timer >= 7.9 and switch == 7.9:
		$FarmerGremlins.attack_prep()
		switch = 8.5
	if timer >= 8.5 and switch == 8.5:
		$FarmerGremlins.scared_cry()
		$FarmerGremlins.attack()
		switch = 10
	if timer >= 10 and switch == 10: 
		$FarmerGremlins.quiet()
		switch = 11.5
	if timer >= 11.5 and switch == 11.5: 
		$FarmerGremlins.announce_run()
		switch = 12
	if timer >= 12 and switch == 12:
		$FarmerGremlins.run_away()
		$Gremlins.chase()
		switch = 14
	if timer >= 14 and switch == 14:
		$FarmerGremlins.quiet()
		switch = 16
	if timer >= 16 and switch == 16:
		emit_signal("end_scene")
		switch += 1

func start_farm_scene(): 
	timer = -1
	switch = 1
	has_started = true



	

