extends Node2D

const speed = 80
const movement_back = 700
var end_x 

var is_left = false

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
	if is_left: 
		position.x -= speed * delta
	else:
		if position.x < end_x:
			position.x += speed * delta
		else: 
			begin_idle()

func go_left(): 
	$AnimatedSprite.flip_h = true
	is_left = true

func begin_walking(): 
	$AnimatedSprite.play("walk")
	state = State.WALK
		
func begin_idle(): 
	state = State.IDLE
	$AnimatedSprite.play("idle")
