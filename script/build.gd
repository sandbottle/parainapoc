extends Node2D

# players
onready var player = get_node('/root/game/player')
onready var camera = get_node('/root/game/camera')

# tilemaps
onready var props = get_parent().get_node('sort/props')
onready var helper = get_parent().get_node('sort/helper')
onready var sort = get_parent().get_node('sort')

# ui
onready var build_ui = get_node('/root/game/build/container')

var buildmode = false
var old_cell_position = Vector2.ZERO
var selected = 'turret'

func _input(event):
	if (Input.is_action_just_pressed('build')):
		if (player.get_node('weapon').weapon):
			player.get_node('weapon').visible = buildmode
		player.allow_move = buildmode
		
		buildmode = !buildmode
		helper.set_cell(old_cell_position.x, old_cell_position.y, -1)
		build_ui.visible = buildmode
		
	if (buildmode):
		player.anim(player.IDLE)
		
		if (event is InputEventMouseButton or InputEventMouseMotion):
			helper.set_cell(old_cell_position.x, old_cell_position.y, -1)
			
			var cell_position = props.world_to_map(get_global_mouse_position())
			helper.set_cell(cell_position.x, cell_position.y, 8)
			
			old_cell_position = cell_position
			
			if (event is InputEventMouseButton):
				if (event.button_index == BUTTON_LEFT && event.pressed):
					if (props.get_cellv(cell_position) == -1):
						props.set_cell(cell_position.x, cell_position.y, 8)
						sort.disable_cell(cell_position)
						sort.render_props_by_cell(cell_position, 8)
					else:
						props.set_cell(cell_position.x, cell_position.y, -1)
						sort.enable_cell(cell_position)
						sort.render_props_by_cell(cell_position, 8, true)
