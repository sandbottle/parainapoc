extends Control

export (NodePath) onready var show_joystick = get_node(show_joystick)
export (NodePath) onready var god_mode = get_node(god_mode)

var content

func _ready():
	var file = File.new()
	
	if (file.file_exists('user://settings.json')):
		file.open('user://settings.json', File.READ)
		content = parse_json(file.get_as_text())[0]
	else:
		file.open('res://gamedata/settings_default.json', File.READ)
		content = file.get_as_text()
		
		file = File.new()
		file.open('user://settings.json', File.WRITE)
		file.store_line(to_json(parse_json(content)))
		
	show_joystick.pressed = content['show_joystick']
	god_mode.pressed = content['god_mode']

func _on_discord_pressed():
	OS.shell_open('https://sandbottle.net/u/discord')
