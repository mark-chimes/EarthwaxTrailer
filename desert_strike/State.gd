extends Object
class_name State

enum Dir {
	NONE = 0,
	LEFT = -1,
	RIGHT = 1,
}

enum Creature {
	MARCH,
	WALK,
	AWAIT_FIGHT,
	FIGHT,
	IDLE,
	DIE,
}

enum Army {
	MARCH, # TODO Army should no longer have these states - it should be handled by separate objects
	BATTLE,
	CAPTURE,
	IDLE,
	DIE,
}
