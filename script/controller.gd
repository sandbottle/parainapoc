extends Control

onready var game = get_node('/root/game/')

var is_sprinting = false
var is_gm_opened = false

func _on_attack_pressed():
	if (is_gm_opened):
		Input.action_press("ui_accept")
		return
		
	Input.action_press('shoot')

func _on_attack_released():
	if (is_gm_opened):
		Input.action_release("ui_accept")
		return
		
	Input.action_release('shoot')

func _on_sprint_pressed():
	is_sprinting = !is_sprinting
	if (is_sprinting):
		Input.action_press("sprint")
		get_node("control/sprint").modulate.r = 0
	else:
		Input.action_release("sprint")
		get_node("control/sprint").modulate.r = 255

func _on_build_mode_pressed():
	pass

func _on_inventory_pressed():
	Input.action_release("inventory")
	get_node("control/sprint").modulate.r = 255
