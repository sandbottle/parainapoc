extends StaticBody2D

onready var game = get_node('/root/game')
onready var game_parent = get_node('/root/game/')

onready var player = get_node('/root/game/player')

onready var timer = get_node('cooldown')
onready var costume = get_node("costumes")

var bullet = load('res://scene/bullet.tscn')

var target = null
var target_list = []
var melee_target_list = []

var direction
var default_direction

var weapon = null
var is_range = false
var is_melee = false

var space_state
var result

var allowshoot = true
var autoshoot = false

func _ready():
	default_direction = !get_parent().get_node("costumes/body").flip_h
	refresh()
	
func set_weapon(s_weapon, s_is_range, s_is_melee):
	weapon = s_weapon
	is_range = s_is_range
	is_melee = s_is_melee
	
	refresh()
	
func refresh():
	visible = weapon != null
	get_node('radius/area').set_deferred('disabled', !is_range)
	get_node("melee/area").set_deferred('disabled', !is_melee)

func shoot(auto = false):
	if (player.allow_move): 
		if (is_range == true && melee_target_list.size() == 0):
			if (allowshoot == true):
				if (target_list.size() != 0):
					if (is_instance_valid(target)):
						direction = sign(target.global_position.x - global_position.x)
					
						if (auto == false):
							space_state = $muzzle.get_world_2d().direct_space_state
							result = space_state.intersect_ray($muzzle.global_position, target.global_position, [self, get_parent()], collision_mask)
						else:
							result = false
					else:
						target_list.erase(0)
						#shoot(auto)
				else:
					result = true
						
				if (player.energy_taken(5)):
					var nowbullet = bullet.instance()
					var a = 0
					
					if (!result):
						if (target_list.size() != 0 && is_instance_valid(target)):
							a = (target.global_position - $muzzle.global_position).angle()
						else:
							a = (Vector2.RIGHT * round(player.last_vector_x)).angle()
					else:
						a = (Vector2.RIGHT * round(player.last_vector_x)).angle()
						#(round(player.last_vector_x) * -1)
					
					nowbullet.start($muzzle.global_position, a + rand_range(-0.05, 0.05), player, target)
				
					game_parent.add_child(nowbullet)
					
					allowshoot = false
					timer.start()
		else:
			pass
			#melee_target.damaged(50)

func _physics_process(_delta):	
	if (weapon != null):
		if (Input.is_action_pressed('shoot')):
			shoot()
			
		if (target_list.size() > 0):
			if (target == null or !is_instance_valid(target) or !target.get('hitable')):
				target = target_list[0]
					
			for t in target_list:
				if (is_instance_valid(target_list[0]) && is_instance_valid(target) && t.get('hitable')):
					if (global_position.distance_to(t.global_position) < global_position.distance_to(target.global_position)):
						target = t
				else:
					target_list.erase(t)
					
			player.aiming = true
			
			if (target.global_position >= global_position):
				player.anim(player.FLIP_R)
			else:
				player.anim(player.FLIP_L)
			
			var v = (target.global_position - global_position).angle()
			costume.rotation = v
		
			if (autoshoot == true):
				space_state = get_world_2d().direct_space_state
				result = space_state.intersect_ray(global_position, target.global_position, [self, get_parent()], collision_mask)
		
				if (!result):
					shoot(true)
					
			var rot = rad2deg(v)
			costume.flip_h = true
			
			if(rot >= -90 and rot <= 90):
				costume.flip_v = false
			else:
				costume.flip_v = true
		else:
			costume.rotation_degrees = 0
			$col.rotation_degrees = 0
			$muzzle.rotation_degrees = 0
			
			player.aiming = false
			
			costume.flip_v = false
			costume.flip_h = player.last_vector_x > 0

func _on_cooldown_timeout():
	allowshoot = true

func _on_radius_body_entered(body):
	if (body.get('hitable') && body.team != 'player' && is_instance_valid(body)):
		target_list.append(body)

func _on_radius_body_exited(body):
	if (body in target_list):
		target_list.erase(body)

func _on_melee_body_entered(body):
	if (body.get('hitable') && body.team != 'player'):
		if (is_instance_valid(body)):
			target_list.erase(body)
		melee_target_list.append(body)

func _on_melee_body_exited(body):
	if (body.get('hitable')):
		if (is_instance_valid(body)):
			target_list.append(body)
		melee_target_list.erase(body)
