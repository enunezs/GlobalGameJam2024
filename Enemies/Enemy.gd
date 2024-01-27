extends CharacterBody2D

enum State {IDLE, PREPARE_TO_ATTACK, FOLLOW, SLIP, DEAD, STOP, BOUNCE}

# Declare member variables here. Break down per state
# IDLE
var idle_time = .5

# PREPARE_TO_ATTACK
var prepare_time = 1.5

# FOLLOW
var speed = 500
var follow_time = 1.0

# DEAD
signal hit

# SLIP
var slip_time = 3.0
var slip_speed = 300

# BOUNCE
var bounce_time = 2.0

# Member variables
var state_transition : bool = true
var current_time: float = 0.0
var target_time: float = 0.0
var state = State.IDLE # start state
var direction = Vector2() # direction to player
var cur_speed = Vector2() # current speed

@onready var player = get_tree().get_root().get_node("Node2D/Player")

@onready var animation_player = $AnimatedSprite2D


# Called when the node enters the scene tree for the first time.
func _ready(): 

	# log error if not found
	if player == null:
		print("Player not found")
		return
	# If unset, set target time
	if target_time < current_time:
		target_time = current_time + idle_time
		state = State.IDLE

	state_transition = true
	var current_time: float = 0.0
	var target_time: float = 0.0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# print enemy state in text
	#print("State: " + str(state))
	
	current_time += delta

	#print current and target time
	#print("Current time: " + str(current_time))
	#print("Target time: " + str(target_time))

	
	match state:
		State.IDLE:
			idle()
		State.PREPARE_TO_ATTACK:
			prepare_to_attack()
		State.FOLLOW:
			follow(delta)
		State.DEAD:
			die()
		State.BOUNCE:
			pass
			
		State.SLIP:
			slip(delta)

func idle():
	# Transtion IN
	if state_transition:
		state_transition = false
		target_time = idle_time
		current_time =0.0

	# Play idle animation
	pass
	
	# If time is up, switch to prepare

	# Transition OUT
	if current_time > target_time:
		state_transition = true
		state = State.PREPARE_TO_ATTACK	

	

func player_hit():
	# Transition IN
	if state_transition:
		state_transition = false
		target_time = 3.0
		current_time =0.0
	set_velocity(Vector2(0,0))

	move_and_slide()	
	
	# Transition OUT
	if target_time < current_time:
		state_transition = true
		state = State.IDLE


func prepare_to_attack(): 
	# Transition IN
	if state_transition:
		state_transition = false
		target_time = prepare_time
		current_time =0.0

	# Prepare to attack behavior here
	
	# Check if player exists
	if player == null:
		print("Player not found")
		state_transition = true
		state = State.STOP
		return
	
	# Get player position, calculate direction to them
	# Rotate towards the player
	direction = player.global_position - global_position
	direction = direction.normalized()
	#rotation = direction.angle()
	
	# Play prepare animation
	
	# If time is up, switch to follow
	# If unset, set target time
	if target_time < current_time:
		state_transition = true
		state = State.FOLLOW

func bounce(delta):
	# Transition IN
	if state_transition:
		state_transition = false
		target_time = bounce_time
		current_time =0.0
		direction = -direction.normalized()
		cur_speed = speed * direction 

	cur_speed = cur_speed * 0.9

		# Move along previous fixed direction

	set_velocity(cur_speed)	
	move_and_slide()	

	# If unset, set target time

	# Transition OUT
	if target_time < current_time:
		state = State.IDLE
		state_transition = true

func follow(delta):
	# Transition IN
	if state_transition:
		state_transition = false
		target_time = follow_time
		current_time =0.0

		direction = direction.normalized()
		cur_speed = speed * direction

	# Move along previous fixed direction
	#direction = direction.normalized()

	set_velocity(cur_speed)	
	move_and_slide()	

	# If unset, set target time

	# Transition OUT
	if target_time < current_time:
		state = State.IDLE
		state_transition = true

func slip(delta):
	# Transition IN
	if state_transition:
		state_transition = false
		target_time = slip_time
		current_time =0.0

	# Play slip animation
	velocity = direction * slip_speed
	global_position += velocity * delta

	# Transition OUT
	if target_time < current_time:
		state_transition = true
		state = State.IDLE


func die():
	hit.emit()
	queue_free()
		

### Collision detection ###
	
func _on_banana_sensor_area_2d_area_entered(area):
	print("Area name: " + area.get_parent().name)
	
	# if area is an item
	if area.get_parent().is_in_group("Item") and area.get_parent().thrown:
		# set state to carrying
		print("Slip!")
		state_transition = true
		state = State.SLIP
		target_time =  slip_time
		current_time = 0 

		area.get_parent().destroy()

	if area.is_in_group("Scenario"):
		state = State.DEAD
