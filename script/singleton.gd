extends Node

var entities
var items
var props

onready var game = get_node_or_null('/root/game')

func _ready():
	get_tree().set_auto_accept_quit(false)
	
	var file_list = ['entities.json', 'items.json', 'props.json']
		
	var file = File.new()
	for now_file in file_list:
		file.open('res://gamedata/' + now_file, File.READ)
		self[now_file.split('.')[0]] = parse_json(file.get_as_text())[0]

	file.close()

func _notification(what):
	if what == MainLoop.NOTIFICATION_WM_QUIT_REQUEST:
		if (is_instance_valid(game)):
			game.savemap()
			game.savegame()
			game.savechest()

		get_tree().quit() 
