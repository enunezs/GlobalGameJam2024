extends Sprite2D

enum State {IDLE, PREPARE_TO_ATTACK, FOLLOW}

# Declare member variables here. Break down per state
# IDLE
var idle_time = .5

# PREPARE_TO_ATTACK
var prepare_time = 1.5

# FOLLOW
var speed = 500
var follow_time = 1.0

# Member variables
var current_time: float = 0.0
var target_time: float = 0.0
var state = State.IDLE # start state
var direction = Vector2() # direction to player
@onready var player = get_tree().get_root().get_node("Node2D/Player")


# Called when the node enters the scene tree for the first time.
func _ready(): 
	#player = get_node("Player") # Replace with your player node's path


	# log error if not found
	if player == null:
		print("Player not found")
		return
	# If unset, set target time
	if target_time < current_time:
		target_time = current_time + idle_time
		state = State.IDLE



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# print enemy state in text
	print("State: " + str(state))
	
	current_time += delta

	#print current and target time
	print("Current time: " + str(current_time))
	print("Target time: " + str(target_time))

	
	match state:
		State.IDLE:
			idle()
		State.PREPARE_TO_ATTACK:
			prepare_to_attack()
		State.FOLLOW:
			follow(delta)

func idle():
	# Play idle animation
	pass
	
	
	# If time is up, switch to prepare
	if current_time > target_time:
		state = State.PREPARE_TO_ATTACK	
		target_time = current_time + prepare_time
			

func prepare_to_attack(): 
	# Prepare to attack behavior here
	# Get player position, calculate direction to them
	# Rotate towards the player
	direction = player.global_position - global_position
	direction = direction.normalized()
	#rotation = direction.angle()
	
	# Play prepare animation
	
	# If time is up, switch to follow
	# If unset, set target time
	if target_time < current_time:
		state = State.FOLLOW
		target_time = current_time + follow_time

func follow(delta):

	# Move along previous fixed direction
	#direction = direction.normalized()
	direction = direction.normalized()
	global_position += direction * speed * delta

	# If unset, set target time
	if target_time < current_time:
		target_time = current_time + idle_time
		state = State.IDLE


