extends CharacterBody2D
# This is the base class for all characters in the game.

# Base states
enum State {IDLE, MOVE, CARRYING, THROWING, STUNNED, DEAD}
# TODO Removed for now. Will add back in later
#PICKING_UP

# Declare member variables here. Break down per state
# IDLE

# MOVE
@export var FRICTION = 500
@export var MAX_SPEED = 300
@export var ACCELERATION = 1500

# PICKING_UP
# Get position of 

# CARRYING
# Get marker for obejct position
@onready var object_holder = get_node("ItemPosMarker")

# THROWING
@onready var axis = Vector2.ZERO


# Member variables
var current_time: float = 0.0
var target_time: float = 0.0
var state = State.MOVE # start state
var item = null # item being carried
var item_holding = false # is player item_holding an item
var direction = Vector2() # direction to player
var last_mouse_pos = Vector2.RIGHT # last mouse position

# Called when the node enters the scene tree for the first time.
func _ready(): 

	# log error if not found
	if object_holder == null:
		print("Player not found")
		return


func _physics_process(delta):
	# print enemy state in text
	#print("State: " + str(state))
	
	current_time += delta

	#print current and target time
	#print("Current time: " + str(current_time))
	#print("Target time: " + str(target_time))

	
	match state:
		State.MOVE:
			move(delta)

		State.CARRYING:
			pick_up()

		State.THROWING:
			throw()
	
func move(delta):
	
	axis = get_input_axis()
	if axis == Vector2.ZERO:
		apply_friction(FRICTION * delta)
		
	else:
		apply_movement(axis * ACCELERATION * delta)
		
	move_and_slide()

func get_input_axis():

	axis.x = int(Input.is_action_pressed("move_right")) - int(Input.is_action_pressed("move_left"))
	axis.y = int(Input.is_action_pressed("move_down")) - int(Input.is_action_pressed("move_up"))
	return axis.normalized()
	

func apply_friction(amount):
	if velocity.length() > amount:
		velocity -= velocity.normalized() * amount
	else:
		velocity = Vector2.ZERO

func apply_movement(accel):
	velocity += accel
	velocity = velocity.limit_length(MAX_SPEED)


func _on_area_2d_area_entered(area):
	print("Area name: " + area.get_parent().name)
	# if area is an item
	if area.get_parent().name == "Banana" and state == State.MOVE:
		# set state to carrying

		state = State.CARRYING
		item = area.get_parent()


	pass # Replace with function body.

# on click
func _input(event):
	# Mouse in viewport coordinates.
	if event is InputEventMouseButton:
		last_mouse_pos = event.position
		print("Mouse Click/Unclick at: ", event.position)
		if event.is_pressed():
			print("Mouse Clicked")
			# if player is carrying an item
			if item_holding:
				state = State.THROWING


func pick_up():
	# set item as child of object holder
	item_holding = true
	var old_transform = item.global_transform
	item.get_parent().remove_child(item)
	add_child(item)
	item.global_transform = old_transform
	# set item as kinematic
	# set item position to object holder position
	item.position = object_holder.position
	#item.set_physics_process(false)
	state = State.MOVE
	
func throw():
	print("Throwing") 
	item_holding = false
	# Disown the child
	# Unparent item, preserve position 
	
	var old_transform = item.global_transform
	remove_child(item)
	get_parent().add_child(item)
	item.global_transform = old_transform

	# throw item
	# set item as not kinematic
	# set item velocity to direction
	item.set_physics_process(true)

	# add force
	direction = (last_mouse_pos - get_global_position()).normalized()
	item.apply_impulse(direction * 100)
	#item.velocity = direction * 100
	item = null


	state = State.MOVE
	pass # Replace with function body.
