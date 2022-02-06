extends Node2D

onready var dialog = get_node("/root/game/dialog/ui")
onready var dialog_name = get_node("/root/game/dialog/ui/dialog-box/vbox/name")
onready var dialog_label = get_node("/root/game/dialog/ui/dialog-box/vbox/label")
onready var timer = get_node("timer")

var dialogs = ['Welcome to the game. Use WASD to move.', 'You can pick a weapon by walking toward to it.', 'To attack, you can use space button.', 'You also can sprint by holding shift when moving.', 'To open your inventory, press Z key, and to close it press ESC key.']
var num = 0
var started = false

func start():
	swap(0)
	var started = true

func swap(num):
	dialog.show()
	dialog_name.text = 'Tutorial'
	dialog_label.text = dialogs[num]

func _input(event):
	if (event is InputEventMouseButton && event.pressed):
		if (num < dialogs.size() && started == true):
			swap(num)
			num += 1
		else:
			dialog.hide()
			
#	if (Input.is_action_pressed("ui_up") or Input.is_action_pressed("ui_down")  or Input.is_action_pressed("ui_left")  or Input.is_action_pressed("ui_right")):
#		haswalk(true)
#
#func haswalk(value):
#	if (value != has_walk):
#		dialog.hide()
#
#		timer.start()
#		yield(timer, "timeout")
#
#		swap(1)
#		has_walk = value
