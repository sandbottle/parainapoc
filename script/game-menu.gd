extends CanvasLayer

#importing resources

onready var player = get_node('/root/game/player')
onready var overlay = get_node("overlay")
onready var game = get_node('/root/game')

#trading
export (NodePath) onready var player_inventory_grid = get_node(player_inventory_grid) 
export (NodePath) onready var trader_inventory_grid = get_node(trader_inventory_grid)
export (NodePath) onready var player_trade_grid = get_node(player_trade_grid) 
export (NodePath) onready var trader_trade_grid = get_node(trader_trade_grid)

# inventory
export (NodePath) onready var inventory_grid = get_node(inventory_grid)

# chest
export (NodePath) onready var player_chest_grid = get_node(player_chest_grid)
export (NodePath) onready var chests_grid = get_node(chests_grid)

var trading
var crafting

# crafting
export (NodePath) onready var craft_parent = get_node(craft_parent)
export (NodePath) onready var craft_box = get_node(craft_box)
export (NodePath) onready var craft_grid = get_node(craft_grid)
export (NodePath) onready var craft_label = get_node(craft_label)

var selected = null setget selected_changed

# preload
var craft_container = preload('res://scene/craft-container.tscn')
var panel = preload('res://scene/panel.tscn')
var notif = preload('res://scene/notif.tscn')

# drag and drop
var is_dragging = false
var drag_object

# ready
func _ready():
	# crafting
	craft_box.modulate.a = 0
		
	for item in global.items:
		if (global.items[item].craftable):
			var now_craft_container = craft_container.instance()
			craft_parent.add_child(now_craft_container)
			now_craft_container.item = item.capitalize()
			now_craft_container.type = global.items[item].type

#code
# trading 
func trade_start():
	trading = Trading.new()
	
	var player_inventory_data = player.inventory.get_data(true)
	trading.temp_player = player_inventory_data[0]
	trading.temp_player_number = player_inventory_data[1]
	
	trading.temp_trader = ['stone']
	trading.temp_trader_number = [10]
	
	pass

#func _on_addplayer_pressed():
#	var nowpanel = panel.instance()
#	nowpanel.celltype = 'trading-player'
#	player_grid.add_child(nowpanel)
#
#func _on_addtrader_pressed():
#	var nowpanel = panel.instance()
#	nowpanel.celltype = 'trading-trader'
#	trader_grid.add_child(nowpanel)

func _on_trade_pressed():
	if (trading.is_trade_valid()):
		var player_data = trading.get_changes(0)
		var trader_data = trading.get_changes(1)
		
		for x in range(player_data[0].size()):
			player.inventory.remove({'item': player_data[0][x], 'number': player_data[1][x]})
			
		for x in range(trader_data[0].size()):
			player.inventory.append({'item': trader_data[0][x], 'number': trader_data[1][x]})
			
# crafting
func craft_start():
	selected = null
	
func selected_changed(value):
	for child in craft_grid.get_children():
		child.queue_free()
	
	selected = value
	craft_box.modulate.a = 1
	
	craft_label.text = selected.item
	
	for item in global.items[selected.item.to_lower()].recipe:
		var panel_instance = panel.instance()
		craft_grid.add_child(panel_instance)
				
		panel_instance.item = item.name
		panel_instance.itemcount = item.number
		
		# func update_inventory(action, item, number, boxtarget):

func _on_craft_pressed():
	if (selected != null):
		var valid = true
		var recipe = global.items[selected.item.to_lower()].recipe
		var production_number = 1

		var player_inventory_data = player.inventory.get_data(true)
		for x in range (recipe.size()): 
			if (not recipe[x].name in player_inventory_data[0] or recipe[x].number * production_number > player_inventory_data[1][player_inventory_data[0].find(recipe[x].name)]):
				valid = false
				break
	
		if (valid):
			for x in recipe:
				player.inventory.remove({'item': x.name, 'number': x.number})
				
			player.inventory.append({'item': selected.item.to_lower(), 'number': 1})
			var now_notif = notif.instance()
			add_child(now_notif)
			now_notif.notif_text = 'Item crafted.'
			now_notif.play()

func _on_button_pressed():
	closed()

func closed():
	for child in get_children():
		child.hide()
		
func opened(type):
	closed()
	
	get_node(type).show()
	overlay.show()
	
	if (type == 'inventory'):
		render_inventory(inventory_grid, player.inventory.get_data(true, false))
		
	elif (type == 'chest'):
		render_inventory(player_chest_grid, player.inventory.get_data(true, false))
		render_inventory(chests_grid, player.gm_opened_sender._inventory.get_data(true, false))
		
	elif (type == 'trading'):
		render_inventory(player_inventory_grid, player.inventory.get_data(true, false))
		render_inventory(trader_inventory_grid, player.gm_opened_sender.inventory.get_data(true, false))
		
	elif (type == 'crafting'):
		craft_start()
	
func render_inventory(target : GridContainer, inventory):
	var children = target.get_children()
	for x in range(children.size()):
		var child = children[x]
		child.reset()
		
		if (inventory[0][x]):
			child.item = inventory[0][x]
			child.itemcount = inventory[1][x]
