extends Node2D


func _ready():
	pass # Replace with function body.

func _on_TimingsController_shoot_first_arrow():
	$Arrow1.shoot()

func _on_TimingsController_shoot_arrows():
	for num in range(2, 32): 
		get_node("Arrow" + str(num)).shoot()
	for num in range(1, 5): 
		get_node("RabbitArrow" + str(num)).shoot()


