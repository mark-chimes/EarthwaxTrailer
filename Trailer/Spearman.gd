extends Node2D

const speed = 80
const movement_back = 500
var end_x 

enum State { 
	IDLE, WALK
}

var state = State.IDLE

func _ready(): 
	end_x = position.x
	position.x -= movement_back

func _process(delta):
	if state == State.WALK:
		walk_process(delta)

func walk_process(delta): 
	if position.x < end_x:
		position.x += speed * delta
	else: 
		begin_idle()

func begin_walking(): 
	$AnimatedSprite.play("walk")
	state = State.WALK
		
func begin_idle(): 
	state = State.IDLE
	$AnimatedSprite.play("idle")
