extends "res://parallax/util/ParallaxObject.gd"
signal attack(this)
signal death(this)
signal creature_positioned(this)

var HealthBar = preload("res://desert_strike/HealthBar.tscn")
var DebugLabel = preload("res://desert_strike/DebugLabel.tscn")

onready var rng = RandomNumberGenerator.new()
var damage

var band
var lane

enum Dir {
	LEFT = -1,
	RIGHT = 1,
}

enum State {
	MARCH,
	WALK,
	AWAIT_FIGHT,
	FIGHT,
	IDLE,
	DIE,
}

var state = State.IDLE
var sprite_dir = Dir.RIGHT
var dir = Dir.RIGHT
var is_in_combat = false
var mute = true

var health = 10
onready var health_bar = HealthBar.instance()
var MAX_HEALTH = 10
var show_health = false
const WALK_SPEED = 5
const END_POS_DELTA = 0.1

var time_between_attacks = 3
var walk_target_x

var is_debug = false
onready var debug_label = DebugLabel.instance()

func _ready(): 
	rng.randomize()
	init_health_bar()
	add_child(debug_label)
	debug_label.position.x = 0
	debug_label.position.y = -96
	#update_debug_label_with_state()

func set_band_lane(new_band, new_lane): 
	band = new_band
	lane = new_lane

func init_health_bar(): 
	add_child(health_bar)
	health_bar.init_health_bar(MAX_HEALTH)
	if not show_health: 
		health_bar.visible = false
func hide_health(): 
	show_health = false
	health_bar.visible = false
	
func update_health_bar(new_health): 
	health_bar.update_health(new_health)

func _process(delta):
	match state:
		State.MARCH:
			real_pos.x += delta * WALK_SPEED * dir
		State.WALK:
			if dir * (walk_target_x - real_pos.x ) < END_POS_DELTA:
				emit_signal("creature_positioned", self)
				return
			real_pos.x += delta * WALK_SPEED * dir
		State.AWAIT_FIGHT: 
			pass
		State.IDLE:
			pass
		State.FIGHT:
			pass
		State.DIE:
			pass

func set_debug_label(label_text): 
	debug_label.get_node("Label").text = label_text
	
func update_debug_label_with_state(): 
	if not is_debug: 
		return 
	
	var label_text
	match state:
		State.MARCH:
			label_text = "march"
		State.WALK: 
			label_text = "walk"
		State.AWAIT_FIGHT: 
			label_text = "await"
		State.FIGHT: 
			label_text = "fight"
		State.IDLE:
			 label_text = "idle"
		State.DIE: 	
			label_text = "" # Don't show labels for the dead
	set_debug_label(label_text)

func set_state(new_state, new_dir):
	# This part is temporary. Should be removed when dead creatures no longer get
	# state information from the army
	if state == State.DIE and (new_state in [State.WALK, State.AWAIT_FIGHT, State.FIGHT, State.IDLE]):
		return
	state = new_state
	
	update_debug_label_with_state()
	dir = new_dir
	match state:
		State.MARCH:
			$AnimatedSprite.play("walk")
		State.WALK:
			$AnimatedSprite.play("walk")
		State.AWAIT_FIGHT:
			$AnimatedSprite.play("idle")
		State.FIGHT:
			$AnimatedSprite.connect("animation_finished", self, "attack_prep_anim_finish")
			$AnimatedSprite.play("attack_prep")
			prepare_attack_strike()
		State.IDLE:
			$AnimatedSprite.play("idle")
		State.DIE:
			$AnimatedSprite.play("die")
			$AnimatedSprite.flip_h = (dir != sprite_dir)
			emit_signal("death", self)
			play_sound_death()
			yield($AnimatedSprite, "animation_finished")
			$AnimatedSprite.frame = $AnimatedSprite.frames.get_frame_count("die")
			$AnimatedSprite.playing = false
			hide_health()
	$AnimatedSprite.flip_h = (dir != sprite_dir)
	
func prepare_attack_strike(): 
	yield(get_tree().create_timer(time_between_attacks), "timeout")
	if state == State.FIGHT: 
		emit_signal("attack", self)
	if state != State.FIGHT: # has to be checked again after attack signal
		return
	$AnimatedSprite.connect("animation_finished", self, "attack_anim_finish")
	$AnimatedSprite.play("attack_strike")
	play_sound_attack()
	prepare_attack_strike()

func take_damage(the_damage): 
	health -= the_damage
	if health <= 0: 
		health = 0
		if state == State.FIGHT:
			set_state(State.DIE, dir)
	update_health_bar(health)

func attack_prep_anim_finish(): 
	$AnimatedSprite.disconnect("animation_finished", self, "attack_prep_anim_finish")
	if state != State.FIGHT: 
		return
	$AnimatedSprite.play("attack_hold")

func attack_anim_finish(): 
	$AnimatedSprite.disconnect("animation_finished", self, "attack_anim_finish")
	if state != State.FIGHT: 
		return
	$AnimatedSprite.connect("animation_finished", self, "attack_prep_anim_finish")
	$AnimatedSprite.play("attack_prep")
	
func play_sound_death():
	if mute: 
		return
	var sounds = $SoundDie.get_children()
	sounds[rng.randi() % sounds.size()].play()

func play_sound_attack():
	if mute: 
		return
	if state != State.FIGHT:
		return
	var sounds = $SoundAttack.get_children()
	sounds[rng.randi() % sounds.size()].play()

func walk_to(new_walk_target_x):
	walk_target_x = new_walk_target_x
	var new_dir
	if new_walk_target_x > real_pos.x:
		new_dir = Dir.RIGHT
	else:
		new_dir = Dir.LEFT
	set_state(State.WALK, new_dir)
