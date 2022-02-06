extends Camera2D

export (NodePath) onready var anchor = get_node(anchor)
var lerp_speed = 0.1
onready var actual_cam_pos := global_position

var lastpos = Vector2()
var pos = Vector2()

func _process(delta):
	pos = lerp(global_position, anchor.global_position, delta * 5)

	if (global_position.distance_to(anchor.global_position) < 12):
		global_position = pos.round()
	else:
		global_position = pos

	#global_position = player.global_position.round()
#	global_position = player.global_position

#func _physics_process(delta):
#	global_position = player.global_position.round()
#	force_update_scroll()
