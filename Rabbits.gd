extends Node2D

var timer = 0

var switch = 1

signal shoot_first_arrow
signal shoot_arrows
signal people_enter

var has_scene_started = false

# Called when the node enters the scene tree for the first time.
func _ready():
	# start_scene()
	pass

func start_scene(): 
	has_scene_started = true
	$Rabbit1.start_idling()
	$Rabbit2.start_hopping()
	$Rabbit3.start_sprinting()
	$Rabbit3.start_grazing()

func _process(delta):
	if has_scene_started == false: 
		return
	timer += delta
	if timer >= 1 and switch == 1:
		switch += 1
		$Rabbit3.start_idling()
	if timer >= 2 and switch == 2:
		switch += 1
		$Rabbit1.start_hopping()
	if timer >= 3 and switch == 3:
		switch += 1
		$Rabbit2.start_hopping()	
	if timer >= 4 and switch == 4:
		switch += 1
		$Rabbit2.start_grazing()	
	if timer >= 5 and switch == 5:
		switch += 1
		$Rabbit1.start_idling()	
	if timer >= 6 and switch == 6:
		switch += 1
		$Rabbit3.start_hopping()	
	if timer >= 7 and switch == 7:
		switch += 1
		$Rabbit1.start_alert()	
		$Rabbit2.start_alert()	
		$Rabbit3.start_alert()	
		$Rabbit4.start_alert()	
	if timer >= 8 and switch == 8:
		switch += 1
	if timer >= 9 and switch == 9:
		switch = 9.7
		$Rabbit1.start_sprinting()	
		$Rabbit2.start_sprinting()	
		$Rabbit3.start_sprinting()	
		$Rabbit4.start_sprinting()	
	if timer >= 9.7 and switch == 9.7:
		switch = 9.8
		$Rabbit1.start_dying()	
	if timer >= 9.8 and switch == 9.8:
		switch = 9.9
		$Rabbit2.start_dying()	
		$Rabbit3.start_dying()	
	if timer >= 9.9 and switch == 9.9:
		switch += 1
		$Rabbit4.start_dying()	
