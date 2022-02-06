extends CanvasLayer

onready var message = get_node("container/vbox/vbox/message")
onready var timer = get_node("timer")
onready var tween = get_node("tween")
onready var banner = get_node("banner")
onready var buttons = get_node("container/vbox/vbox")
onready var copyright = get_node("copyright")

export var skip = false
var version = ProjectSettings.get_setting('global/version')
var file = File.new()
var reset_count = 0
var screen_size : Vector2
	
func set_system():
	var content = {
		'version': version
	}
	
	file.open('user://system.dat', File.WRITE)
	file.store_line(to_json(content))
	file.close()
	
func _ready():
	screen_size = get_viewport().size
	buttons.modulate.a = 0
	copyright.modulate.a = 0
	
	# banner
	var banner_pos = banner.rect_position.y
	banner.rect_position.y = 0 - banner.rect_size.y
	
	timer.wait_time = 0.7
	timer.start()
	yield(timer, "timeout")
	
	tween.interpolate_property(banner, 'rect_position:y', banner.rect_position.y, banner_pos, 0.6, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	tween.start()
	yield(tween, "tween_all_completed")
	
	# buttons	
	timer.start()
	yield(timer, "timeout")
	
	tween.interpolate_property(buttons, 'modulate:a', 0, 1, 0.3, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	tween.start()
	
	tween.interpolate_property(copyright, 'modulate:a', 0, 1, 0.3, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	tween.start()
	
	if (file.file_exists('user://system.dat')):
		file.open('user://system.dat', File.READ)
		var content = parse_json(file.get_line())
		
		if (content['version'] != version):
			message.text = '[WARNING] You running different version game in same save file. It will return something unexpected. I\'m highly recommend you to reset the game. This message shown because you are using the alpha game version.'
	
	if (skip):
		get_tree().change_scene("res://scene/game.tscn")
	else:
		get_node('container/vbox/vbox/version').text = 'v. ' + version

func _on_start_pressed():
	get_tree().change_scene("res://scene/game.tscn")
	set_system()

func _on_reset_pressed():
	if (reset_count == 6):
		message.text = 'Cheat mode activated'
	else:
		var dir = Directory.new()
		dir.remove("user://save_game.dat")
		
		message.text = 'Game resetted'
	
	reset_count += 1
