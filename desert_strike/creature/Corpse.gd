extends "res://parallax/util/ParallaxObject.gd"
signal disappear(this)

var timer = 0
const CORPSE_TIME = 3

func _ready():
	$AnimatedSprite.play("dying")
	$AnimatedSprite.connect("animation_finished", self, "_on_animation_finished")

func _process(delta):
	if $AnimatedSprite.get_animation() == "dying":
		return
	if timer >= CORPSE_TIME: 
		emit_signal("disappear", self)
	timer += delta		

func _on_animation_finished(): 
	if $AnimatedSprite.get_animation() == "dying":
		$AnimatedSprite.play("dead")
