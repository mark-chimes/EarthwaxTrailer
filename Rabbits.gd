extends Node2D

var timer = 0

var switch = 1

signal shoot_first_arrow
signal shoot_arrows
signal people_enter

# Called when the node enters the scene tree for the first time.
func _ready():
	$Rabbit1.start_idling()
	$Rabbit2.start_hopping()
	$Rabbit3.start_sprinting()
	$Rabbit3.start_grazing()
	
func _process(delta):
	timer += delta
	if timer >= 1 and switch == 1:
		# emit_signal("people_enter") #DEBUG
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
		emit_signal("shoot_first_arrow")
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
		emit_signal("shoot_arrows")
		switch += 1
		$Rabbit1.start_sprinting()	
		$Rabbit2.start_sprinting()	
		$Rabbit3.start_sprinting()	
		$Rabbit4.start_sprinting()	
	if timer >= 10 and switch == 10:
		switch += 1
		$Rabbit1.start_dying()	
		$Rabbit2.start_dying()	
		$Rabbit3.start_dying()	
		$Rabbit4.start_dying()	
	if timer >= 11 and switch == 11:
		emit_signal("people_enter")
		switch += 1
		# pass
