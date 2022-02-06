extends CanvasLayer
onready var npc_name = $"ui/dialog-box/vbox/name"
onready var content = $"ui/dialog-box/vbox/label"

var dialogs
var current

signal dialog_done

func _ready():
	var file = File.new()
	if (file.file_exists("res://gamedata/dialogs.json")):
		file.open("res://gamedata/dialogs.json", File.READ)
		dialogs = parse_json(file.get_as_text())
	else:
		dialogs = [{'name': 'System', 'message': 'Gamefile corrupted.'}]
		
	file.close()
	
	#play_dialog(1)
	pass
	
func _input(event):
	if (current): 
		if event is InputEventKey and event.pressed:
			if event.scancode == KEY_ENTER:
				$ui.hide()
		
				if (current['nextid'] != null):
					play_dialog(current['nextid'])
				else:
					current = null
		
		elif (event is InputEventMouseButton):
			if (event.button_index == BUTTON_LEFT and event.pressed):
				$ui.hide()
				
				if (current['nextid'] != null):
					play_dialog(current['nextid'])
				else: 
					current = null
		
func play_dialog(id):
	if (dialogs.size() <= id):
		current = dialogs[id - 1]
		npc_name.text = current['name']
		content.text = current['message']
		
		$ui.show()
	else:
		$ui.hide()
		
	emit_signal("dialog_done")
	
