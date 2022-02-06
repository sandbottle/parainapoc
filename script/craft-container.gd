extends MarginContainer

# get child
onready var name_label = get_node("hbox/vbox/name")
onready var type_label = get_node("hbox/vbox/category")
onready var parent = get_node('/root/game/game-menu')
onready var panel = get_node("hbox/con/panel1")

var item : String setget set_item
var type : String setget set_type
var inhover = false

func _ready():
	panel.item = 'stone'

func set_item(value):
	item = value
	
	name_label.text = value
	panel.item = value
	
func set_type(value):
	type = value
	
	type_label.text = value
	
func _input(event):
	if (event is InputEventMouseButton && inhover):
		if (event.button_index == BUTTON_LEFT && event.pressed):
			parent.selected = self

func _on_container_mouse_entered():
	inhover = true
	
func _on_container_mouse_exited():
	inhover = false
