extends YSort

var astar = AStar2D.new()

onready var props = get_node('props')
onready var ground = get_node('ground')
onready var size = ground.get_used_rect().size

# resources
var props_scene = load('res://scene/props.tscn')
var door_scene = load('res://scene/door.tscn')
var turret_scene = load('res://scene/turret.tscn')

var last
var obstacles = []
var id_list = {}

func render_props():
	for x in range (global.props.size()):
		var now = global.props[x]
		
		for y in props.get_used_cells_by_id(now.id):
			var now_instance
			# specific configuration
			if (now.type == 'props'):
				now_instance = props_scene.instance()
			elif (now.type == 'turret'):
				now_instance = turret_scene.instance()
			
			# global configuration
			now_instance.global_position = props.map_to_world(y) + Vector2(16, 16)
			now_instance.type = now.name
			now_instance.name = str(generate_id(y))
			now_instance.add_to_group('props')
			
			props.add_child(now_instance)
		
func render_props_by_id(cell_id, derender = false):
	if (!derender):
		var now
		for prop in global.props:
			if (prop.id == cell_id):
				now = prop
				break
		
		for y in props.get_used_cells_by_id(cell_id):
			var now_instance
			# specific configuration
			if (now.type == 'props'):
				now_instance = props_scene.instance()
			elif (now.type == 'turret'):
				now_instance = turret_scene.instance()
				
			# global configuration
			now_instance.global_position = props.map_to_world(y) + Vector2(16, 16)
			now_instance.type = now.name
			now_instance.name = str(generate_id(y))
			now_instance.add_to_group('props')
				
			props.add_child(now_instance)
	else:
		for y in props.get_used_cells_by_id(cell_id):
			props.get_node(generate_id(y)).queue_free()

func render_props_by_cell(cell_pos, cell_id, derender = false):
	if (!derender):
		var now
		for prop in global.props:
			if (prop.id == cell_id):
				now = prop
				break
				
		var now_instance
		# specific configuration
		if (now.type == 'props'):
			now_instance = props_scene.instance()
		elif (now.type == 'turret'):
			now_instance = turret_scene.instance()
		
		# global configuration	
		now_instance.global_position = props.map_to_world(cell_pos) + Vector2(16, 16)
		now_instance.type = now.name
		now_instance.name = str(generate_id(cell_pos))
		now_instance.add_to_group('props')
			
		props.add_child(now_instance)
	else:
		props.get_node(str(generate_id(cell_pos))).queue_free()
	
func render():
	astar.clear()
	astar.reserve_space(size.x * size.y)
	
	var used = ground.get_used_cells()

	for id in ground.tile_set.get_tiles_ids():
		if ground.tile_set.tile_get_shape_count(id) > 0:
			obstacles.append(id)
	
	for cell in used:
		if (_in_bounds(cell)):
			var id = generate_id(cell)

			astar.add_point(id, cell)

	for cell in used:
		if (_in_bounds(cell)):
			var id = generate_id(cell)

			var tile_id = ground.get_cellv(cell)
			var nears = [
#				cell + Vector2.UP,
#				cell + Vector2.LEFT,
#				cell - Vector2.ONE
				Vector2(cell.x, cell.y + 1),
				Vector2(cell.x, cell.y - 1),
				Vector2(cell.x + 1, cell.y),
				Vector2(cell.x - 1, cell.y)
			]
					
			for near in nears:
				if _in_bounds(near):
					var target_id = generate_id(near)
					if (not target_id in obstacles) and astar.has_point(target_id):
						astar.connect_points(id, target_id, true)

			if (tile_id in obstacles):
				astar.set_point_disabled(id)

	var propused = props.get_used_cells()

	for cell in propused:
		if (_in_bounds(cell)):
			var id = generate_id(cell)
			var tile_id = props.get_cellv(Vector2(cell.x, cell.y))
			if props.tile_set.tile_get_shape_count(tile_id) > 0:
				astar.set_point_disabled(id, true)
	
#	for i in size.x:
#		cur_y = start_num.y
#		for j in size.y:
#			var coor = Vector2(cur_x, cur_y)
#			var id = generate_id(coor)
#
#			astar.add_point(id, coor, 1)
#
#			if (ground.get_cellv(coor) != -1):
#				var near_me = [Vector2(cur_x + 1, cur_y), Vector2(cur_x - 1, cur_y), Vector2(cur_x, cur_y + 1), Vector2(cur_x, cur_y - 1), Vector2(cur_x + 1, cur_y -1), Vector2(cur_x - 1, cur_y + 1), Vector2(cur_x + 1, cur_y + 1), Vector2(cur_x - 1, cur_y - 1)]
#				for here in near_me:
#					var here_id = generate_id(here)
#					if (astar.has_point(here_id)):
#						astar.connect_points(id, here_id, true)
#
#			if ground.get_cell(cur_x, cur_y) != ground.INVALID_CELL:
#				astar.set_point_disabled(id, false)
#
#			cur_y += 1
#		cur_x += 1

func disable_cell(cell):
	if (astar.has_point(generate_id(cell))):
		astar.set_point_disabled(generate_id(cell), true)

func enable_cell(cell):
	if (astar.has_point(generate_id(cell))):
		astar.set_point_disabled(generate_id(cell), false)
		
# generate an unique id for cells
func generate_id(cell):
	return abs((cell.x - ground.position.x) + (cell.y - ground.position.y) * size.x)
	
func _in_bounds(point):
	return point.x >= 0 && point.y >= 0 && point.x < size.x && point.y < size.y
	
func get_way(start, end, global = true):
	var start_id
	var end_id
	
	if (global):
		start_id = generate_id(ground.world_to_map(start))
		end_id = generate_id(ground.world_to_map(end))
	else:
		start_id = generate_id(start)
		end_id = generate_id(end)
	
	if (_in_bounds(ground.world_to_map(start)) && _in_bounds(ground.world_to_map(end))):
		var points = []
		var p = Array(astar.get_point_path(start_id, end_id))
			
		for point in p:
			points.append(ground.to_global(ground.map_to_world(point)) + Vector2(16, 16))
		
		return points
