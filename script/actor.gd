extends KinematicBody2D
class_name Actor

# signal
signal killed

# include modules
onready var nav = get_node('/root/game/nav/sort')
onready var bump = get_node("bump-manager")

# timers
onready var idle_timer = get_node('idle-timer')
onready var atk_timer = get_node('atk-timer')
onready var effect = get_node('effect')

# hurtbox
onready var body_hurtbox = get_node("hurtbox")
onready var foot_hurtbox = get_node("foot")

onready var costumes = get_node("costumes")
onready var hitbox = get_node("hitbox")

# preload
var fct = preload("res://scene/fct.tscn")

var hitable = true

# personal data
var team : String
var actor_name : String

export(String, 'passive', 'self_defence', 'ally', 'hostile', 'boss', 'aggressive') var type

var speed : int
var hp : int
var damage : int

var target = null
var target_list = []
var following = null

var path = []
var direction = 0
var transition = 0
var dir = 0
var spawn_point =  Vector2.ZERO
var idle_point = Vector2.ZERO

var patrol_location
var patrol_reached = false
var is_in_atk_radius = false
var iscatching = false

var input_vector = Vector2.ZERO

var move = Vector2.ZERO
var knockback = Vector2.ZERO
var velocity : Vector2

# state machine variable
enum {
	IDLE,
	CATCHING,
	DIE,
	PATROL,
	FOLLOWING
}
var state = IDLE

func _new(_actor_name):
	var data = global.entities[_actor_name]
	
	if (data):
		# set name
		name = _actor_name
		actor_name = _actor_name
		
		# set type 
		type = data['type']
		
		# set stats
		speed = data['speed']
		hp = data['hp']
		if (type != 'passive'): 
			damage = data['damage']
			
		team = data['team']
		
		match (type):
			'passive':
				get_node("atk-radius/area").disabled = true
				#get_node("follow-radius/area").disabled = true
				
				state = CATCHING
	else:
		print('invalid entity')

func damaged(_damage, is_body = true, _sender = null):
	var fct_i = fct.instance()
	add_child(fct_i)
	fct_i.show_value(str(_damage), Vector2(0, -80), 1, PI * 0.5, false) 
	
	#if (sender in hurtbox.get_overlapping_areas()):
	if (_damage >= hp):
		emit_signal("killed")

		hp = 0
		
		# deactivate collision
		get_node('col').set_deferred('disabled', true)
		hitable = false
		
		z_index = 1
		costumes.play('die')
		
		var instance = load('res://scene/item.tscn')
		var drop = instance.instance()
		drop.global_position = global_position
		
		get_parent().call_deferred('add_child', drop)
		
		modulate = Color(0.5, 0.5, 0.5)
		
		get_node("dead").start()
		atk_timer.stop()
	else:
		hp = hp - _damage;
		effect.interpolate_property(costumes, "modulate:a", 0, 1, 0.2)
		effect.start()
		
		#knockback -= Vector2(100, 100)

func _physics_process(delta):
	if (hp > 0):
		knockback = knockback.move_toward(Vector2.ZERO, 200 * delta)
		knockback = move_and_slide(knockback)
		
		match state:
			PATROL: 
				if (!patrol_reached):
					costumes.play('walk')
					if (global_position.distance_to(idle_point) < 1 or idle_point == Vector2.ZERO):
						costumes.play('idle')
						patrol_reached = true
						
						randomize()
						idle_point = Vector2(global_position.x + rand_range(-10, 10), global_position.y + rand_range(-10, 10))
					
						randomize()
						idle_timer.set_wait_time(rand_range(2, 5))
						
						idle_timer.start()
						
					# code that break the idling process
					if (type == 'hostile'):
						if (target_list.size() > 0):
							var space_state = get_world_2d().direct_space_state
							var result = space_state.intersect_ray(global_position, target_list[0].global_position, [self], collision_mask)
							if (result && result.collider.name == target_list[0].name):
								state = CATCHING
					elif (type == 'ally'):
						if (following):
							if (global_position.distance_to(following.global_position) > 20):
								state = FOLLOWING
						
					move = idle_point - global_position
					velocity = velocity.move_toward(move.normalized() * speed, 300 * delta)
					if (bump.colliding()):
						velocity += bump.get_push_vector() * delta * 400
					move = move_and_slide(velocity)
					
					dir = idle_point.x - global_position.x
					costumes.flip_h = dir > 0
				
			FOLLOWING:
				if (following):
					var space_state = get_world_2d().direct_space_state
					var result = space_state.intersect_ray(global_position, following.global_position, [self], collision_mask)
					
					if (result && result.collider.name != following.name):
						path = nav.get_way(global_position, following.global_position)

						if (path && path.size() > 1):
							path.remove(0)

							var distance = global_position.distance_to(path[0])
							if (distance > 5):
								global_position = global_position.linear_interpolate(path[0], (speed * delta) / distance)
								dir = path[0].x - global_position.x
							else:
								path.remove(0)
						else:
							state = PATROL
					else:
						if (global_position.distance_to(following.global_position) > 20):
							move = following.global_position - global_position
							velocity = velocity.move_toward(move.normalized() * speed, 300 * delta)
							if (bump.colliding()):
								velocity += bump.get_push_vector() * delta * 200
							move = move_and_slide(velocity)
						else:
							state = PATROL
				#	move_and_collide(move.normalized() * speed * delta)
				
			CATCHING:
				if (target_list.size() > 0):
					for t in target_list:
						if (target != null && is_instance_valid(target)):
							if (global_position.distance_to(t.global_position) < global_position.distance_to(target.global_position)):
								target = t
						else:
							target = t

				move = target_list[0].global_position - global_position

				var space_state = get_world_2d().direct_space_state
				var result = space_state.intersect_ray(global_position, target_list[0].global_position, [self], collision_mask)

				if (result && result.collider.name != target_list[0].name):
					path = nav.get_way(global_position, target_list[0].global_position)

					if (path && path.size() > 1):
						path.remove(0)

						var distance = global_position.distance_to(path[0])
						if (distance > 5):
							global_position = global_position.linear_interpolate(path[0], (speed * delta) / distance)
							dir = path[0].x - global_position.x
						else:
							path.remove(0)
					else:
						state = PATROL
				else:
					velocity = velocity.move_toward(move.normalized() * speed, 300 * delta)
					if (type != 'aggressive'):
						if (bump.colliding()):
							velocity += bump.get_push_vector() * delta * 400
					
					move = move_and_slide(velocity)
					dir = target_list[0].global_position.x - global_position.x

				costumes.play('walk')

				costumes.flip_h = dir > 0
				hitbox.scale.x = -1 if (dir > 0) else 1
					
#				if (abs(y_distance) < 100):
#					if (abs(x_distance) > 30):
#						costumes.play('walk')
#						if (direction <= move[0]):
#							if (move[0] != 0):
#								costumes.flip_h = true
#						else:
#							costumes.flip_h = false
#					else:
#						if (y_distance < 0):
#							costumes.play('walk_up')
#						else:
#							costumes.play('walk_down')
#				else:
#					if (y_distance < 0):
#						costumes.play('walk_up')
#					else:
#						costumes.play('walk_down')

func _on_followradius_body_entered(body):
	match (type):	
		'passive':
			if (body != self && body.name == 'player'):
				target_list.append(body)
		'ally':
			if (body != self && body.name == 'player'):
				following = body
				state = FOLLOWING
		'hostile':
			if (body != self && body.get('hitable')):
				if (team != body.get('team')):
					state = CATCHING
					target_list.append(body)
		'aggressive':
			if (body != self && body.get('hitable')):
				target_list.append(body)
				state = CATCHING
		
func _on_followradius_body_exited(body):
	match (type):
		'passive':
			if (body != self && body.name == 'player'):
				target_list.erase(body)
		'ally':
			if (body == following):
				following = null
				state = PATROL
		'hostile':
			if (body in target_list): 
				target_list.erase(body)
		'aggressive':
			if (body in target_list):
				target_list.erase(body)
		
	if (type != 'passive' && type != 'ally'):
		if (target_list.size() <= 0):
			state = PATROL

func _on_idletimer_timeout():
	patrol_reached = false
	
	randomize()
	idle_timer.set_wait_time(rand_range(2, 5))
	idle_timer.stop()

func _on_atktimer_timeout():
	randomize()
	atk_timer.wait_time = randi() % 3 + 1
	costumes.play('die')
	
	if (target and is_in_atk_radius and target in hitbox.get_overlapping_bodies()):
		if (is_instance_valid(target) and target.get('hitable')):
			target.damaged(damage)

func _on_atkradius_body_entered(body):
	if (target_list.size() != 0):
		match(type):
			'hostile':
				if (body == target_list[0]):
					atk_timer.start()
					is_in_atk_radius = true
					
			'aggressive':
				if (body == target_list[0]):
					atk_timer.start()
					is_in_atk_radius = true

func _on_atkradius_body_exited(body):
	if (target_list.size() != 0):
		match(type):
			'hostile':
				if (body == target_list[0]):
					atk_timer.start()
					is_in_atk_radius = false
			
			'aggressive':
				if (body == target_list[0]):
					atk_timer.stop()
					is_in_atk_radius = false

func _on_dead_timeout():
	effect.interpolate_property(self, "modulate:a", 1, 0, 0.5, Tween.TRANS_LINEAR, Tween.EASE_IN)
	effect.start()
	
	yield(effect, "tween_all_completed")
	queue_free()
