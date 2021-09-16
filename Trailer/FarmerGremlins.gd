extends Node2D

var speed = 20
var full_speed = 90
var is_running = false

func huh(): 
	$AnimatedSprite.play("alert")
	$Speechbox.visible = true
	$Speechbox.text = "?"

func quiet(): 
	#$AnimatedSprite.play("alert")
	$Speechbox.visible = false


func scared_cry(): 
	# $AnimatedSprite.play("alert")
	$Speechbox.visible = true
	$Speechbox.text = "Get away!"
	
func _process(delta): 
	if is_running: 
		if speed < full_speed: 
			speed += full_speed*delta
		position.x -= speed * delta

func point(): 
	$AnimatedSprite.play("point")
	$AnimatedSprite.flip_h = true

func attack_prep(): 
	$Speechbox.visible = true
	$Speechbox.text = "!"
	$AnimatedSprite.play("attack")
	$AnimatedSprite.speed_scale = 0
	$AnimatedSprite.flip_h = false
	
func attack(): 
	$AnimatedSprite.play("attack")
	$AnimatedSprite.speed_scale = 1
	$AnimatedSprite.flip_h = false
	
func announce_run(): 
	$Speechbox.visible = true
	$Speechbox.text = "Fuck this!"
	# $AnimatedSprite.flip_h = false
	
func run_away(): 
	is_running = true
	$AnimatedSprite.flip_h = true
	$AnimatedSprite.play("run")
