extends Node2D
class_name Inventory

var items = []
var item_number = []

func _init(number):
	for _x in range(number):
		items.append(null)
		item_number.append(0)

func resize(number):
	var difference = items.size() - number
	if (difference < 0):
		for _x in range(difference):
			items.append(null)
			item_number.append(0)
	else:
		var remain = abs(difference)
		var null_count = items.count(null)
		
		for _x in range(items.count(null)):
			var to_remove = items.find(null)
			items.remove(to_remove)
			item_number.remove(to_remove)
				
		if (null_count <= remain):
			remain -= null_count
			
			for x in range(remain):
				var to_remove = items.size() - 1 - x
				items.remove(to_remove)
				item_number.remove(to_remove)

func append(_items, first = false, force = false):
	if (!first):
		if (!force):
			if (typeof(_items) == TYPE_ARRAY):
				for x in _items: 
					if (items.find(x.item) != -1):
						item_number[items.find(x.item)] += x.number
					else:
						var index = items.find(null)
						items[index] = x.item
						item_number[index] = x.number
					#x.number
			else:
				if (items.find(_items.item) != -1):
					item_number[items.find(_items.item)] += _items.number
				else:
					var index = items.find(null)
					items[index] = _items.item
					item_number[index] = _items.number
		else:
			if (typeof(_items) == TYPE_ARRAY):
				for x in range(_items.size()):
					var index = _items[x].pos
					 
					items[index] = _items[x].item
					item_number[index] += _items[x].number
			else:
				var index = _items.pos
					 
				items[index] = _items.item
				item_number[index] += _items.number
					
	else:
		for x in range(_items.size()): 
			items[x] = _items[x].item
			item_number[x] = _items[x].number
		# items.number
	#if (items.size() > 1)):
	
func remove(_items):
	if (typeof(_items) == TYPE_ARRAY):
		for x in _items: 
			var now_item = items.find(x.item)
			if (now_item != -1):
				if (item_number[now_item] > x.number):
					item_number[now_item] -= x.number 
				else:
					items[now_item] = null
					item_number[now_item] = 0
	else:
		var now_item = items.find(_items.item)
		if (now_item != -1):
			if (item_number[now_item] > _items.number):
				item_number[now_item] -= _items.number 
			else:
				items[now_item] = null
				item_number[now_item] = 0

#if (inventory.has(item)):
#	if (itemcount[inventory.find(item)] > number):
#		itemcount[inventory.find(item)] -= number
#	else:
#		itemcount.remove(inventory.find(item))
#		inventory.erase(item)
#else:
#	inventory.erase(item)
	
func get_data(raw = false, filter = true):
	var result = []
	
	var items_clone = items.duplicate()
	var item_number_clone = item_number.duplicate()
		
	if (filter):
		for _x in range(items_clone.count(null)):
			var index = items_clone.find(null)
			items_clone.remove(index)
			item_number_clone.remove(index)
	
	if (raw):
		result = [
			items_clone,
			item_number_clone
		]
	else:
		for x in range(items_clone.size()):
			result.append({
				'a': x,
				'item': items_clone[x],
				'number': item_number_clone[x]
			})
			
	return result
	
func move(from, to, force = false):
	if (!force):
		if (!items[to]):
			items[to] = items[from]
			item_number[to] = item_number[from]
			
			items[from] = null
			item_number[from] = 0
		else:
			if (items[to] == items[from]):
				item_number[to] += item_number[from]
				items[from] = null
				item_number[from] = 0
			else:
				var to_item = items[to]
				var to_item_number = item_number[to]
				
				items[to] = items[from]
				item_number[to] = item_number[from]
				
				items[from] = to_item
				item_number[from] = to_item_number
	else:
		items[to] = items[from]
		item_number[to] = item_number[from]
			
		items[from] = null
		item_number[from] = 0
		
func move_to_different(to_array, item, number, to):
	var index = items.find(item)
	
	if (index != -1):
		var to_moved_item = items[index]
		var to_moved_item_number = item_number[index]
		
		if (number > to_moved_item_number):
			number = to_moved_item_number
		
		to_array.append({
			'item': to_moved_item,
			'number': number,
			'pos': to
		}, false, true)
		
		remove({
			'item': to_moved_item,
			'number': number 
		})
