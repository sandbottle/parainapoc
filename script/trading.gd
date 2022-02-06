extends Node2D

class_name Trading
var temp_player = []
var temp_player_number = []

var temp_trader = []
var temp_trader_number = []

var inventory : Array = []
var itemcount: Array = []

var inventory_change : Array = []
var itemcount_change: Array = []

var target = []
var target_number = []

var player_change = []
var player_change_number = []

var trader_change = []
var trader_change_number = []

func _init():
	temp_player = []
	temp_player_number = []
	temp_trader = []
	temp_trader_number = []
	
	player_change = []
	player_change_number = []
	trader_change = []
	trader_change_number = []

func update_inventory(action, item, number, boxtarget):
	if (boxtarget == 0):
		inventory = temp_player
		itemcount = temp_player_number
		
		inventory_change = player_change
		itemcount_change = player_change_number
	else:
		inventory = temp_trader
		itemcount = temp_trader_number
		
		inventory_change = trader_change
		itemcount_change = trader_change_number
	
	if (action == 0):
		if (inventory.has(item)):
			itemcount[inventory.find(item)] += number
		else:
			inventory.append(item)
			itemcount.append(number)
	elif (action == 1):
		if (inventory.has(item)):
			if (itemcount[inventory.find(item)] > number):
				itemcount[inventory.find(item)] -= number
			else:
				itemcount.remove(inventory.find(item))
				inventory.erase(item)
		else:
			inventory.erase(item)
			
	#changes
	if (action == 1):
		if (inventory_change.has(item)):
			itemcount_change[inventory_change.find(item)] += number
		else:
			inventory_change.append(item)
			itemcount_change.append(number)
	elif (action == 0):
		if (inventory_change.has(item)):
			if (itemcount_change[inventory_change.find(item)] > number):
				itemcount_change[inventory_change.find(item)] -= number
			else:
				itemcount_change.remove(inventory_change.find(item))
				inventory_change.erase(item)
		else:
			inventory_change.erase(item)
			
func is_trade_valid():
	var player_value = 0
	var trader_value = 0
	
	for x in range(player_change.size()):
		player_value += global.items[player_change[x]].trade_value * player_change_number[x]  
		
	for x in range(trader_change.size()):
		trader_value += global.items[trader_change[x]].trade_value * trader_change_number[x]  
	
	return player_value >= trader_value
	
func is_contain(boxtarget, item, number = 1):
	if (boxtarget == 0):
		target = temp_player
		target_number = temp_player_number
	else:
		target = temp_trader
		target_number = temp_trader_number
	
	return target_number[target.find(item)] >= number

func get_inventory(mode):
	if (mode == 0):
		return [temp_player, temp_player_number]
	else:
		return [temp_trader, temp_trader_number]

func get_changes(mode):
	if (mode == 0):
		return [player_change, player_change_number]
	else:
		return [trader_change, trader_change_number]
		
func clear_changes(mode):
	if (mode == 0):
		player_change = []
		player_change_number = []
	else:
		trader_change = []
		trader_change_number = []
