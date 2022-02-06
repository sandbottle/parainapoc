extends Node2D

onready var player = get_node('/root/game/player')

export var allowtrading = true
export var npcname = 'Dave'

var inventory

func _ready():
	inventory = Inventory.new(15)
	inventory.append({
		'item': 'stone',
		'number': 15
	})

func _on_detectradius_body_entered(body):
	if (body.name == 'player'):
		player.gm_opened = 'trading'
		body.gm_opened_sender = self
		#player.target_sell = sell_items

#		for x in range(sell_items.size()):
#			var panel = grid.get_node('panel' + str(x + 1))
#			panel.itemcount = 1000
#			panel.item = 'Rock'

func _on_detectradius_body_exited(body):
	if (body.name == 'player'):
		player.gm_opened = null
		body.gm_opened_sender = null
