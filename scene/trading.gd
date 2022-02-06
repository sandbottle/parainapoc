extends MarginContainer

onready var player_grid = get_node('vbox/hbox/vbox/vbox/grid')
onready var trader_grid = get_node('vbox/hbox/vbox2/vbox/grid')
onready var player = get_node('/root/game/player')

var panel = preload('res://scene/panel.tscn')

var itemname = ['stone', 'iron', 'wood']
var itemvalue = [10, 15, 20]

var player_temp = []
var player_count = []

var trader_temp = []
var trader_count = []

var traded = []
var tradedcount = []

var tradertraded = []
var tradertradedcount = []

func _ready():
	pass

func count_value():
	var player_value = 0
	var trader_value = 0
	
	var player_container = player_grid.get_children()
	var trader_container = trader_grid.get_children()
	
	for p in player_container:
		player_value += itemvalue[itemname.find(p.item)] * p.itemcount
		
		if (p.name != 'add'):
			if (p.item and p.item != ''):
				if (traded.has(p.item)):
					tradedcount[traded.find(p.item)] += p.itemcount
				else:
					traded.append(p.item)
					tradedcount.append(p.itemcount)
		
	for p in trader_container:
		trader_value += itemvalue[itemname.find(p.item)] * p.itemcount
	
		if (p.name != 'add'):
			if (p.item and p.item != ''):
				if (tradertraded.has(p.item)):
					tradertradedcount[tradertraded.find(p.item)] += p.itemcount
				else:
					tradertraded.append(p.item)
					tradertradedcount.append(p.itemcount)
		
	
	if (player_value != 0 && trader_value != 0):
		return (player_value / trader_value) >= 1 
	else:
		return false

func _on_trade_pressed():
	if (count_value()):
		for t in range(traded.size()):
			for x in tradedcount[t]:
				player.update_inventory(player.INV_REMOVE, traded[t])
		
		for t in range(tradertraded.size()):
			for x in tradertradedcount[t]:
				player.update_inventory(player.INV_APPEND, tradertraded[t])
				
		for g in player_grid.get_children():
			if (g.name != 'add'):
				g.queue_free()
				
		for g in trader_grid.get_children():
			if (g.name != 'add'):
				g.queue_free()
		
		traded = []
		tradedcount = []
		tradertraded = []
		tradertradedcount = []
		
		player.temp_inventory = [] + player.inventory
		player.temp_itemcount = [] + player.itemcount

func _on_addtrader_pressed():
	var nowpanel = panel.instance()
	nowpanel.celltype = 'trading-trader'
	trader_grid.add_child(nowpanel)
	
func _on_addplayer_pressed():
	var nowpanel = panel.instance()
	nowpanel.celltype = 'trading-player'
	player_grid.add_child(nowpanel)
