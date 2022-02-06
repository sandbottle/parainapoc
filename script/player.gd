extends KinematicBody2D

export (int) var speed = 150
var default_speed = speed

var team = 'player'
var hitable = true

var is_die = false
var curPos = Vector2()
var running = false
var gm_opened = null setget change_ui_button
var gm_opened_sender
var inventory_open = false

var velocity = Vector2()
var last_vector_x = 0
var dir
var flip = false

enum {
	WALK,
	IDLE,
	FLIP_R,
	FLIP_L
}

# stats and inventory
var max_hp = 100
var max_energy = 1000

var hp = max_hp
var energy = max_energy

var inventory

# common variable
var indoor
var is_work = false
var aiming = false
var allow_move = true

# get other tilemaps
onready var game = get_node('/root/game/')
onready var props = get_node('/root/game/nav/sort/props')
onready var ui = get_node('/root/game/canvas/ui')

#get child nodes
onready var effect = get_node("effect")
onready var costumes = get_node("costumes").get_children()
onready var progress = get_node("action-proggres")
onready var action_timer = get_node("action-bar-timer")
onready var extra_timer = get_node("extra-timer")
onready var body_hurtbox = get_node("hurtbox")
onready var foot_hurtbox = get_node("foot")

# game menu
onready var game_menu = get_node('/root/game/game-menu')
onready var trading = get_node('/root/game/game-menu/trading')

# get controller
onready var controller = get_node('/root/game/canvas/controller')
onready var attack_button = get_node('/root/game/canvas/controller/control/attack/')

# load scenes
var fct = preload("res://scene/fct.tscn")

func _ready():
	get_node('/root/game/canvas/ui').hp = hp
	get_node('/root/game/canvas/ui').energy = energy
	
#action timer
func move_action_bar(second):
	if (second != 0):
		progress.value = 0
		action_timer.wait_time = second * 0.01
		action_timer.start()
		progress.show()
		
func _on_actionbartimer_timeout():
	if (progress.value < 100):
		progress.value += 1
	else:
		action_timer.stop()
		progress.hide()
		
func _on_regen_timeout():
	if (is_die == false):
		if (!Input.is_action_pressed(('sprint')) && !Input.is_action_pressed(('shoot'))):
			if (energy <= max_energy - 1):
				if (hp > max_hp * 0.5):
					energy += 1
			#update_energy(energy)
		
		if (hp <= max_hp):
			if (hp < max_hp * 0.5):
				hp += 0.2
			else:
				hp += 0.1
			#update_hp(hp)
			
		get_node('/root/game/canvas/ui').hp = hp
		get_node('/root/game/canvas/ui').energy = energy
			
func damaged(damage, is_body = true, sender = null):
	if (!is_body):
		if (not sender in foot_hurtbox.get_overlapping_areas()):
			return
		
	if (damage > ui.hp):
		is_die = true
		
		get_node('/root/game/pause-overlay').show()
		get_node('/root/game/die/container').show()
		
		get_node('regen').stop()
		
		set_collision_mask_bit(1, false)
		get_node('col').disabled = true
		
		var item_pre = preload('res://scene/item.tscn')
		for item in inventory.get_data():
			var item_instance = item_pre.instance()
			item_instance.global_position = global_position
			game.add_child(item_instance)
	else:
		hp = hp - damage;
		effect.interpolate_property($costumes, "modulate:a", 0, 1, 0.2)
		effect.start()
		
		var fct_i = fct.instance()
		add_child(fct_i)
		fct_i.show_value(str(damage), Vector2(0, -80), 1, PI * 0.5, false)
		
		get_node('/root/game/canvas/ui').hp = hp

func energy_taken(taken):
	if (energy - taken > 0):
		energy -= taken
		
		get_node('/root/game/canvas/ui').energy = energy
			
		return true
	else:
		return false

func anim(animmode):
	var animlist = ['walk', 'idle']

	if (animmode == FLIP_R):
		flip = true
	elif (animmode == FLIP_L):
		flip = false
	else:
		for n in costumes:
			n.play(animlist[animmode])
			
	for n in costumes:
		n.flip_h = flip

func change_ui_button(value):
	gm_opened = value
	if (is_instance_valid(controller)):
		controller.is_gm_opened = value != null
		if (value != null):
			attack_button.get_node('costume').frame = 4
		else:
			attack_button.get_node('costume').frame = 0

func _process(_delta):
	velocity = Vector2()
	
	if (Input.is_action_pressed('sprint') && (Input.is_action_pressed('ui_right') or Input.is_action_pressed('ui_left') or Input.is_action_pressed('ui_up') or Input.is_action_pressed('ui_down'))):
		if (energy > 0):
			speed = default_speed * 1.5
			energy -= 0.5
		else:
			speed = default_speed
	else:
		speed = default_speed

	if (is_die == false):
		running = false	
		
		if (!is_work && allow_move):
			var input_vector = Vector2.ZERO
			input_vector.x = Input.get_action_strength('ui_right') - Input.get_action_strength('ui_left')
			input_vector.y = Input.get_action_strength('ui_down') - Input.get_action_strength('ui_up')
			input_vector = input_vector.normalized()
			
			if (aiming == false):
				if (input_vector.x != 0):
					last_vector_x = round(input_vector.x)
					
					if (input_vector.x > 0):
						anim(FLIP_R)
					else:
						anim(FLIP_L)
			
			var playerpos = Vector2(round(get_global_position()[0]), round(get_global_position()[1]))
			var tile = props.world_to_map(playerpos)
			
			if (curPos != tile):
				curPos = tile
				#var _tileid = props.get_cell(int(curPos[0]), int(curPos[1]))
				#get_node('/root/game/console/container/pos').text = str(tile)
		
			if (input_vector != Vector2.ZERO):
				anim(WALK)
					
				velocity = velocity.move_toward(input_vector * speed, speed)
			else:
				anim(IDLE)
				velocity = velocity.move_toward(Vector2.ZERO, speed)
		
			velocity = move_and_slide(velocity.round(), Vector2.UP)

#for ui
func _input(event):
	if Input.is_action_pressed("ui_accept"):
		if (gm_opened != null):
			game_menu.opened(gm_opened)

#				var inventory_data = inventory.get_data(true, false)
#				for x in range(inventory_data[0].size()):
#					var panel = get_node('/root/game/game-menu/trading/vbox/hbox/player/container/scroll/trader_grid/panel' + str(x + 1))
#					panel.reset()
#					if (inventory_data[0][x]):
#						panel.item = inventory_data[0][x]
#						panel.itemcount = inventory_data[1][x]
						
#			elif (gm_opened == 'crafting'):
#				get_node('/root/game/game-menu').craft_start()
#
#			elif (gm_opened == 'chest'):
#				var inventory_data = inventory.get_data(true, false)
#				for x in range(inventory_data[0].size()):
#					var panel = get_node('/root/game/game-menu/chest/vbox/vbox/hbox/grid/panel' + str(x + 1))
#					panel.reset()
#					if (inventory_data[0][x]):
#						panel.item = inventory_data[0][x]
#						panel.itemcount = inventory_data[1][x]
			
	if (Input.is_action_pressed("ui_cancel")):
		game_menu.closed()
		inventory_open = false
			
	if (Input.is_action_just_pressed("inventory")):
		game_menu.opened('inventory')
		inventory_open = true
			
	if (Input.is_action_just_pressed("dig")):
		if (is_work == false):
			anim(IDLE)
			move_action_bar(3)
			
			extra_timer.wait_time = 3
			extra_timer.start()
			is_work = true
			
			yield(extra_timer, "timeout")
			
			is_work = false
			
	# debug function
	if event is InputEventKey and event.pressed and game.debug:
		if Input.is_action_pressed("add_item"):
			inventory.append({
				'item': 'stone',
				'number': 10
			})
			
			get_node('weapon').set_weapon('gun', true, false)
	
func update_indoor_state():
	indoor = !indoor
	
	if (indoor == false):
		$light.hide()
		get_node('/root/game/light-level').hide()
	else:
		$light.show()
		get_node('/root/game/light-level').show()
