extends Node2D

@export var spawner_enabled: bool = true;
@export var spawn_target: PackedScene # Target for spawner
@export var spawn_interval: float = 3.0 # Seconds between spawns
@export var spawn_limit: int = 3 # Maximum number of mobs onscreen

var _spawn_speed: float = 1.0 / spawn_interval
var _spawn_quantity: float 
var rng = RandomNumberGenerator.new()
var active_mob_count = 1

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func spawn():
	var mob = spawn_target.instantiate()
	var screenSize = get_viewport().get_visible_rect().size
	
	var rndX = rng.randi_range(screenSize.x*0.4, screenSize.x*0.6)
	var rndY = rng.randi_range(screenSize.y*0.4, screenSize.y*0.6)
	print("Spawning at: ", rndX, rndY)
	mob.position = Vector2(rndX, rndY)
	add_child(mob)
	active_mob_count += 1

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	_spawn_quantity += delta * _spawn_speed
	if _spawn_quantity >= 1:
		var spawn_count = min(floor(_spawn_quantity), spawn_limit-active_mob_count)
		_spawn_quantity -= spawn_count
		for index in int(spawn_count):
			spawn()
