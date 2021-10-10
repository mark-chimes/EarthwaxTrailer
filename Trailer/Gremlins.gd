extends Node2D

func start_gremlins(): 
#	$Gremlin1.begin_dying()
#	$Gremlin2.begin_dying()
#	$Gremlin3.begin_dying()
#	$Gremlin4.begin_dying()
	
	
	$Gremlin1.begin_walk()
	$Gremlin2.begin_walk()
	$Gremlin3.begin_walk()
	$Gremlin4.begin_walk()

	$Gremlin5.begin_walk()
	$Gremlin6.begin_walk()

func kill_one(): 
	$Gremlin3.begin_dying()

func chase(): 
	$Gremlin1.ready_chase()
	$Gremlin2.ready_chase()
	$Gremlin4.ready_chase()
	$Gremlin5.ready_idle()
	$Gremlin6.ready_idle()
	
func second_chase():
	$Gremlin5.begin_chase()
	$Gremlin6.begin_chase()

