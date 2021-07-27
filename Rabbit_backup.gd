extends Node2D

const SPRINT_TIME = 11.0/15.0
const SIT_TIME = 3.0/15.0
const COOL_TIME = 1.0/15.0
const SPRINT_SPEED = 50
const COOL_SPEED = 10

var sprint_state = SprintState.SITTING

enum SprintState { 
	SPRINTING,
	SITTING,
	COOLING	
}

var sprint_state_time = 0

func _ready():
	$AnimatedSprite.frame = 0

func _process(delta):

	if sprint_state == SprintState.SITTING:
		sprint_state_time += delta
		if sprint_state_time > SIT_TIME: 
			sprint_state = SprintState.SPRINTING
			sprint_state_time = 0
	elif sprint_state == SprintState.SPRINTING:
		position.x += delta*SPRINT_SPEED
		sprint_state_time += delta
		if sprint_state_time >= SPRINT_TIME: 
			sprint_state = SprintState.COOLING
			sprint_state_time = 0
	elif sprint_state == SprintState.COOLING:
		position.x += delta*COOL_SPEED
		sprint_state_time += delta
		if sprint_state_time >= COOL_TIME: 
			sprint_state = SprintState.SITTING
			sprint_state_time = 0
