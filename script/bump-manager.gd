extends Area2D

func colliding():
	var areas = get_overlapping_areas()
	return areas.size() > 0

func get_push_vector():
	var areas = get_overlapping_areas()
	var push_vector = Vector2.ZERO
	
	if (colliding()):
		var area = areas[0]
		
		if (area != self):
			push_vector = area.global_position.direction_to(global_position)
	
	return push_vector