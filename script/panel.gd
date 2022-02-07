extends Panel

export var item : String = '' setget updateitem
export var itemcount = 0 setget updatelabel

onready var root = get_node('/root/game/game-menu')
onready var trading = get_node('/root/game/game-menu/trading')
#onready var overlay = get_node('/root/game/game-menu/trading/inventory-overlay')
onready var player = get_node('/root/game/player')
onready var costume = get_node("costumes")

export var celltype : String

var currentpath
var default_pos

var inhover = false
var drag
var drag_texture
var is_players
var cellindex

func _ready():
	if (!celltype):
		celltype = str(self.get_path()).split('/')[4]
	currentpath = str(self.get_path()).split('/')
	currentpath.remove(currentpath.size() -1)
	currentpath.remove(0)
	
	is_players  = 'player_grid' in currentpath
	default_pos = costume.global_position
	
	cellindex = int(name.replace('panel', '')) - 1
	
func reset():
	itemcount = 0
	item = ''
	
	$counter.hide()
	costume.hide()
	
func updateitem(itemname):
	if (itemname != ''):
		itemname = itemname.to_lower()
		item = itemname
		
		var item_data = global.items[itemname]
		if (item_data):
			costume.frame = item_data.skin
		else:
			costume.frame = 0
		
		costume.show()
	
func updatelabel(number):
	itemcount = number
	
	if (number > 0):
		$counter.show()
		if (number < 999):
			$counter.text = str(number)
		else: 
			$counter.text = '999+'
	else:
		reset()

func _input(event):	
	pass
#	if (event is InputEventMouseButton && inhover):
#		if (event.button_index == BUTTON_LEFT && event.pressed):
#
#			if (celltype == 'trading-player'):
#				overlay.target = self
#
#				var mode
#				if (len(item) <= 0):
#					mode = 'show'
#				else:
#					mode = 'hide'
#
#				overlay.show_overlay(rect_global_position + (rect_size / 2), 'player', mode)
#
#			elif (celltype == 'trading-trader'):
#				overlay.target = self
#
#				var mode	
#				if (len(item) <= 0):
#					mode = 'show'
#				else:
#					mode = 'hide'
#
#				overlay.show_overlay(rect_global_position + (rect_size / 2), 'trader', mode)
#
#			elif (celltype == 'crafting'):
#				pass
#
#			elif (celltype == 'overlay'):
#				overlay.selected = self
#				var scroller = overlay.get_node('container/vbox/hbox/number')
#				scroller.max_value = int(itemcount)
#		elif (event.button_index == BUTTON_WHEEL_DOWN && event.pressed):
#			if (itemcount > 0):
#				if (celltype == 'trading'):
#					#move_trade_item(item)
#					pass

func get_drag_data(position):
	if (celltype == 'inventory' or celltype == 'trading' or celltype == 'chest'):
		if (item):
			var preview_sprite = Sprite.new()
			preview_sprite.texture = costume.texture
			preview_sprite.scale = costume.scale
			preview_sprite.hframes = costume.hframes
			preview_sprite.vframes = costume.vframes
			preview_sprite.frame = costume.frame
			
			var preview = Control.new()
			preview.add_child(preview_sprite)

	#	var preview = Label.new()
	#	preview.text = 'hello world'
	#
			set_drag_preview(preview)
		
			return self

func can_drop_data(position, data):
	if (celltype == 'inventory' or celltype == 'trading' or celltype == 'chest'):
		if (data):
			if (data.celltype == 'trading'):
				if (data.is_players == is_players):
					return true
			else:
				return true
	
func drop_data(_pos, data):
	if (celltype == 'inventory' or celltype == 'trading' or celltype == 'chest'):
		if (data != self):
			if (data.item == item):
				updateitem(data.item)
				updatelabel(data.itemcount + itemcount)
				
				data.reset()
			else:
				if (item == ''):
					updateitem(data.item)
					updatelabel(data.itemcount)
					data.reset()
				else:
					var data_item = data.item
					var data_itemcount = data.itemcount
					
					data.updateitem(item)
					data.updatelabel(itemcount)
					
					updateitem(data_item)
					updatelabel(data_itemcount)
				
			if (data.currentpath == currentpath):
				var temp_from
				if (data.celltype == 'chest'):
					temp_from = player.inventory if (data.is_players) else player.gm_opened_sender._inventory
				else:
					temp_from = player.inventory
				
				temp_from.move(data.cellindex, cellindex)
			else:
				if (celltype == 'chest'):
					var temp_from
					var temp_to
					
					if (is_players):
						temp_from = player.gm_opened_sender._inventory
						temp_to = player.inventory
					else:
						temp_from = player.inventory
						temp_to = player.gm_opened_sender._inventory
						
					temp_from.move_to_different(temp_to, item, itemcount, cellindex)

func _on_panel1_gui_input(event):
#	if (event is InputEventMouseButton && event.pressed):
#		chest.get_node()
#		trading.get_node('vbox/hbox/trader/container/scroll/trader_grid/panel1').updateitem(item)
#		trading.get_node('vbox/hbox/trader/container/scroll/trader_grid/panel1').updatelabel(1)
	return
