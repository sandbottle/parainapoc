extends Node2D

export(String, 'crafting_bench', 'sign', 'spawner', 'spike', 'chest', 'pickable') var type

onready var game = get_node('/root/game/')
onready var cooldown = get_node('cooldown')

onready var detector = get_node("body/detector")

var actor = load('res://scene/actor.tscn')

func disable_collision():
	get_node("body/interact-radius/area").disabled = true
	get_node("body/interact-radius/area2").disabled = true
	
func disable_area():
	get_node("body/col").disabled = true

func disable_detector():
	detector.get_node('area').disabled = true

var _max_spawned = 1
var _spawned
var _sealed = false
var _rand = RandomNumberGenerator.new()

# trap
var _is_trap_active = false
var _trap_target = []

# chest
var _inventory

func _ready():
	match (type):
		'spawner':
			disable_collision()
			disable_area()
			disable_detector()
			
			_spawned = 0
#			spawner_location = props.get_used_cells_by_id(32)
#			tile_size = props.cell_size * 2

			if (game.spawn_zombie == true):
				randomize()

				for _i in range(round(_max_spawned * 0.5) - round(rand_range(0, _max_spawned * 0.5 - 1))):
					_spawn()
					
					cooldown.start()
					
					_spawned += 1
		'spike':
			disable_collision()
			disable_area()
			
			cooldown.wait_time = 1
			cooldown.start()
		'pickabke':
			disable_detector()
		'chest':
			disable_detector()
			_inventory = Inventory.new(10)
# extra function

func _remove():
	var props = get_node('/root/game/nav/sort/props')
	var pos = props.world_to_map(global_position)
	props.set_cell(pos.x, pos.y, -1)
	
	queue_free()

# trap
func _spawn():
	var enemy = actor.instance()
	enemy._new('basic_zombie')

	_rand.randomize()
	
	var spawn_pos = Vector2(_rand.randf_range(global_position.x, global_position.x + 64), _rand.randf_range(global_position.y, global_position.y + 64))
	
	enemy.position = spawn_pos
	#enemy.spawn_point = spawn_pos
	
	enemy.connect("killed", self, "_zombie_killed")
	
	get_parent().add_child(enemy)

func _zombie_killed():
	if (_spawned - 1 == _max_spawned):
		cooldown.start()
		
	_spawned -= 1

# signal

func _on_interactradius_body_entered(body):
	match (type):
		'crafting_bench':
			if (body.name == 'player'):
				body.gm_opened = 'crafting'
				body.gm_opened_sender = self
				
		'chest':
			if (body.name == 'player'):
				body.gm_opened = 'chest'
				body.gm_opened_sender = self
			
		'pickable':
			if (body.name == 'player'):
				get_node('/root/game/player/weapon').set_weapon('gun', true, false)
				_remove()

func _on_interactradius_body_exited(body):
	match (type):
		'crafting_bench':
			if (body.name == 'player'):
				body.gm_opened = null
				body.gm_opened_sender = null
		'chest':
			if (body.name == 'player'):
				body.gm_opened = null
				body.gm_opened_sender = null

func _on_cooldown_timeout():
	match (type):
		'spawner':
			if (_sealed == false && game.allow_respawn):
				_spawn()
				
				randomize()
				cooldown.wait_time = rand_range(3, 5)
				
				_spawned += 1
				if (_spawned > _max_spawned):
					cooldown.stop()
			else:
				cooldown.stop()
				
		'spike':
			for target in _trap_target:
				if (is_instance_valid(target)):
					target.damaged(5, false, detector)

func _on_detector_body_entered(body):
	match (type):
		'spike':
			if (body.get_class() == 'KinematicBody2D'):
				_trap_target.append(body)

func _on_detector_body_exited(body):
	match (type):
		'spike':
			if (body.get_class() == 'KinematicBody2D'):
				_trap_target.erase(body)
