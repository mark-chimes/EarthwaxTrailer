extends Node2D


export var sprint_speed = 50

const HOP_HEIGHT = 10
const HOP_SPEED = 40
var hop_time = 0
var start_y = 0

enum State { 
	ALERT, IDLE, HOP, SPRINT, GRAZE, DIE
}

var state  = State.SPRINT

func _ready(): 
	start_grazing()

func _process(delta):
	match state: 
		State.IDLE: 
			idle_process(delta)
		State.ALERT: 
			alert_process(delta)
		State.GRAZE: 
			graze_process(delta)
		State.HOP: 
			hop_process(delta)	
		State.SPRINT: 
			sprint_process(delta)
		State.DIE: 
			die_process(delta)
			
func start_idling(): 
	state = State.IDLE
	$AnimatedSprite.play("idle")
	
func start_alert(): 
	state = State.ALERT
	$AnimatedSprite.play("alert")
	var frame_offset = floor(rand_range(0, 29))
	print("Frame offset: ", frame_offset)
	$AnimatedSprite.set_frame(frame_offset)

func start_grazing(): 
	state = State.GRAZE
	$AnimatedSprite.play("graze")
		
func start_hopping(): 
	state = State.HOP
	start_y = position.y
	hop_time = 0
	$AnimatedSprite.play("hop")
	$AnimatedSprite.frame = 0
	
func start_sprinting(): 
	state = State.SPRINT
	$AnimatedSprite.play("sprint")

func start_dying(): 
	state = State.DIE
	$AnimatedSprite.play("die")
	print("X: " + str(position.x))
	print("Y: " + str(position.y))
	
func idle_process(_delta): 
	pass

func alert_process(_delta): 
	pass
	
func graze_process(_delta): 
	pass

func die_process(_delta): 
	pass

func hop_process(delta): 
	hop_time += delta*6
	
	if hop_time >= 6: 
		hop_time = 0
	
	var hop_calc = (hop_time - 4.5)/1.5
	hop_calc = hop_calc*hop_calc

		
	if hop_time >= 3:
		print(str(hop_calc))
		position.y = start_y -HOP_HEIGHT + hop_calc * HOP_HEIGHT
		position.x += delta*HOP_SPEED
	else: 
		position.y = start_y
		
func sprint_process(delta): 
	position.x += delta*sprint_speed

func _on_AnimatedSprite_animation_finished():
	if state == State.DIE:
		$AnimatedSprite.stop()
		$AnimatedSprite.set_frame(3)
