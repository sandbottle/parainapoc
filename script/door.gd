extends StaticBody2D

onready var player = get_node('/root/game/player')

var pressed = false
var indoor

func _ready():
	yield(get_node('/root/main'), "ready")
		
	indoor = player.indoor
	get_node('/root/game/roof').visible = !indoor
	
func _on_doorsensor_body_exited(body):
	get_node('/root/game/roof').visible = indoor
	indoor = !indoor
	
	player.indoor = indoor

func _on_dooropener_body_entered(_body):
	pass # Replace with function body.

#func _on_doorsensor_body_entered(body):
#	if (body != self && body.name == 'player' && indoor == false && pressed == false):
#		player.update_indoor_state()
#		indoor = !indoor
#		$"door-sensor/area".set_deferred('disabled', true)
#		$"door-sensor-2/area".set_deferred('disabled', false)
#
#		pressed = true
#
#func _on_doorsensor2_body_entered(body):
#	if (body != self && body.name == 'player' && indoor == true && pressed == false):
#		player.update_indoor_state()
#		indoor = !indoor
#		$"door-sensor/area".set_deferred('disabled', false)
#		$"door-sensor-2/area".set_deferred('disabled', true)
#
#		pressed = true
#
#func _on_doorsensor2_body_exited(body):
#	if (body != self && body.name == 'player' && pressed == true):
#		pressed = false
#
#func _on_doorsensor_body_exited(body):
#	if (body != self && body.name == 'player' && pressed == true):
#		pressed = false
