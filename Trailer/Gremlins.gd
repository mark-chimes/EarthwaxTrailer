extends Node2D

func start_gremlins(): 
	$Gremlin1.begin_walk()
	$Gremlin2.begin_walk()
	$Gremlin3.begin_walk()
	$Gremlin4.begin_walk()

func chase(): 
	$Gremlin1.ready_chase()
	$Gremlin2.ready_chase()
	$Gremlin3.ready_chase()
	$Gremlin4.ready_chase()
