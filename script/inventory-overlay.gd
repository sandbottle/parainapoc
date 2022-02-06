extends Node2D

#onready var player = get_node('/root/game/player')
onready var grid = get_node("container/vbox/grid")
onready var game_menu = get_node('/root/game/game-menu')

var number
var item_panel = load('res://scene/panel.tscn')
var panel_num = 0
var target = null
var selected = null
var namelist = []
var lasttype

enum {
	INV_APPEND,
	INV_REMOVE
}

func _ready():
	hide()
	pass
	
func show_overlay(pos, type, mode):	
	$container/vbox/hbox/number.value = 1
	
	if mode == 'show':
		$container.show()
		$remove.hide()
		
		if (lasttype != type):
			for g in grid.get_children():
				grid.remove_child(g)
				g.queue_free()
			
			namelist = []
			lasttype = type
			panel_num = 0
			
		if (type == 'player'):
			number = game_menu.trading.temp_player.size()
		elif (type == 'trader'):
			number = game_menu.trading.temp_trader.size()
			
		#print(number, ':', panel_num)
			
		if (number != panel_num):
			for g in grid.get_children():
				grid.remove_child(g)
				g.queue_free()
				
			namelist = []
			for x in number:
				var current = item_panel.instance()
				grid.add_child(current)
				namelist.append(current.name)
			panel_num = number

		if (type == 'player'):
			for y in number:
				var current = get_node("container/vbox/grid/" + namelist[y])
				current.itemcount = game_menu.trading.temp_player_number[y]
				current.item = game_menu.trading.temp_player[y]
				current.celltype = 'overlay'
		elif (type == 'trader'):
			for y in number:
				var current = get_node("container/vbox/grid/" + namelist[y])
				current.itemcount = 1000
				current.item = game_menu.trading.temp_trader[y]
				current.celltype = 'overlay'
	elif mode == 'hide':
		$container.hide()
		$remove.show()

	self.global_position = pos
	
	show()

func _on_button_pressed():
	selected = null
	
	hide()

func _on_submit_pressed():	
	if (selected):
		if (target.itemcount != 0):
			pass
			
		#target.itemcount = selected.itemcount
		target.itemcount = int($container/vbox/hbox/number.value)
		target.item = selected.item

		if (lasttype == 'player'):
			game_menu.trading.update_inventory(1, target.item, target.itemcount, 0)
		else:
			game_menu.trading.update_inventory(1, target.item, target.itemcount, 1)
	
		target = null
		
		hide()
		
func _on_remove_pressed():
	if (target.itemcount != 0):
		pass
	
	if (lasttype == 'player'):
		game_menu.trading.update_inventory(0, target.item, target.itemcount, 0)
	else:
		game_menu.trading.update_inventory(0, target.item, target.itemcount, 1)
		
	target.itemcount = 0
	target.item = ''

	hide()
