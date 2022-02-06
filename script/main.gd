extends Node2D

#onready var game = get_node('v-con/v/game')

# player
onready var player = get_node("player")
onready var weapon = get_node('player/weapon')

# tilemap
onready var props = get_node("nav/sort/props")
onready var nav = get_node('nav/sort')
onready var helper = get_node('nav/sort/helper')

# pause
onready var shader = get_node("canvas/shader/player")
onready var pause_button = get_node("canvas/ui/hbox/pause")
onready var pause_menu = get_node("canvas/pause-menu")

onready var controller = get_node("canvas/controller")

# respawn
onready var respawn = get_node('die/container/vbox/button')

# autosave
onready var autosave = get_node("autosave")

# global game setting
export var allow_respawn = true
export var spawn_zombie = true
export var use_loading = true
export var debug : bool = false

func _ready():
	# prining debug message
	print('Paradise in Apocalypse - Debug Mode')
	print('For bug report purpose, send message to bug-report@sandbottle.net with subject "Paradise in Apocalypse" subject.')
	print('')
	
	if (OS.get_name() != 'Android' and !debug):
		controller.queue_free()
	else:
		controller.show()
	
	var file = File.new()
	
	var to_check = [
		'save_game.dat', 
		'map_save.dat',
		'chest_save.dat'
	]
	var all_available = true
	for now_to_check in to_check:
		if (!file.file_exists('user://' + now_to_check)):
			all_available = false
			break
	
	var new_player = false
	if (all_available):
		loadgame()
		loadmap()
		loadchest()
	else:
		print('save file not found, making the new one ...')
		
		if (file.file_exists("res://gamedata/default.json")):
			file.open("res://gamedata/default.json", File.READ)
			var content = parse_json(file.get_as_text())
			
			savegame(content)
			loadgame()
			
			savemap()
			loadmap()
			
			savechest()
			loadchest()
			print('success')
			
			new_player = true
		else:
			print('default save file not found. please contact developer (manu@sandbottle.net) and report this.')
		
	file.close()
	
	# binding pause
	pause_button.connect("pressed", self, "_on_pause_pressed")
	pause_menu.get_node('container/vbox/return').connect("pressed", self, "_on_return_pressed")

	# binding respawn
	respawn.connect("pressed", self, "_on_button_pressed")

	shader.play('in')
	yield(shader, "animation_finished")
	
	if (new_player):
		get_node("tutorial").start()

# game function
func savegame(content = null):
	if (!content):
		content = {
		'x': player.global_position.x,
		'y': player.global_position.y,
		'indoor': player.indoor,
		'inventory': player.inventory.get_data(false, false),
		"weapon": weapon.weapon,
		"is_range": weapon.is_range,
		"is_melee": weapon.is_melee 
	}

	var file = File.new()
	file.open("user://save_game.dat", File.WRITE)
	file.store_line(to_json(content))
	file.close()
	
func loadgame():
	var file = File.new()
	file.open("user://save_game.dat", File.READ)
	var content = parse_json(file.get_line())
	file.close()
	
	# set coordinates
	var coordinates = Vector2(round(content.x), round(content.y))
	player.global_position = coordinates
	get_node("camera").global_position = coordinates
	
	# set environtment
	player.indoor = content.indoor or false
	
	# set inventory
	player.inventory = Inventory.new(15)
	player.inventory.append(content.inventory, true)
	
	# set weapon
	weapon.set_weapon(content.weapon, true, false)
	
# map functions
func savemap():	
	var file = File.new()
	file.open('user://map_save.dat', File.WRITE)
	
	var content = []
	
	for cell in props.get_used_cells():
		var id = props.get_cellv(cell)
		content.append({'x': cell.x, 'y': cell.y, 'id': id})
		
	file.store_line(to_json(content))

func loadmap():
	var file = File.new()
	file.open("user://map_save.dat", File.READ)
	var content = parse_json(file.get_line())
	
	file.close()
	
	var used = props.get_used_cells()
	for cell in used:
		props.set_cell(cell.x, cell.y, -1)
	
	for cell in content:
		props.set_cell(cell.x, cell.y, cell.id)
	nav.render()
	nav.render_props()
	
# chest functions
func savechest():
	var file = File.new()
	
	file.open('user://chest_save.dat', File.WRITE)
	var content = []
	for x in props.get_used_cells_by_id(8):
		var id = nav.generate_id(x)
		content.append({id: props.get_node(str(id))._inventory.get_data(false, false)})

	file.store_line(to_json(content))
	
func loadchest():
	var file = File.new()
	
	file.open("user://chest_save.dat", File.READ)
	var content = parse_json(file.get_line())
	
	for x in content:
		if (x):
			var key = x.keys()[0]
			content.append(props.get_node(str(key))._inventory.append(x[key], true))
	
	file.close()
	
# puuse

func _on_return_pressed():
	savegame()
	savemap()
	
	get_tree().paused = false
	get_tree().change_scene("res://scene/home.tscn")
	
func _on_pause_pressed():
	var is_paused = get_tree().paused
	
	get_tree().paused = !is_paused
	pause_menu.visible = !is_paused

	if (!is_paused):
		get_node("canvas/ui/hbox/pause/player").play('pause')
		get_node('canvas/ui/hbox/stats').modulate.a = 0
		get_node('canvas/action-buttons/').modulate.a = 0
	else:
		get_node("canvas/ui/hbox/pause/player").play('pause-backward')
		get_node('canvas/ui/hbox/stats').modulate.a = 1
		get_node('canvas/action-buttons/').modulate.a = 1
	
	if (is_instance_valid(controller)):
		controller.visible = is_paused
	
	get_node('pause-overlay').visible = !is_paused
	
# respawn
func _on_button_pressed():
	player.global_position = Vector2(64, 64)
	
	player.set_collision_mask_bit(1, true)
	player.get_node('col').disabled = false
		
	player.is_die = false
	player.hp = 100

	get_node("player/regen").start()

	get_node('pause-overlay').hide()
	get_node('die/container').hide()

func _on_autosave_timeout():
	savegame()
	savemap()
	savechest()
