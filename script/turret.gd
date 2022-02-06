extends KinematicBody2D

var bullet = load('res://scene/bullet.tscn')

onready var game = get_node('/root/game')
onready var timer = get_node('atk-cooldown')
onready var player = get_node('/root/game/player')

# personal data
var hp = 100

var team = 'player'
var type = ''

var hitable = true

var target = []
var allowshoot = true
var result
var direction
var space_state

func shoot():
	if (allowshoot == true):
		if (target.size() != 0):
			#direction = sign(target[0].global_position.x - self.global_position.x)
		
			#space_state = get_world_2d().direct_space_state
			#result = space_state.intersect_ray(global_position, target[0].global_position, [self], collision_mask)
			result = false

			if (!result):
				if (target.size() != 0):
					var nowbullet = bullet.instance()
							
					var a = (target[0].global_position - global_position).angle()
					nowbullet.start(get_node("muzzle").global_position, a + rand_range(-0.05, 0.05), self, target[0])
					game.call_deferred('add_child', nowbullet)
		
		allowshoot = false
		timer.start()
		
func damaged(_damage, is_body = true, _sender = null):
	if (_damage >= hp):
		queue_free()
	else:
		hp = hp - _damage;
#		effect.interpolate_property($costumes, "modulate:a", 0, 1, 0.2)
#		effect.start()
		
#		var fct_i = fct.instance()
#		add_child(fct_i)
#		fct_i.show_value(str(_damage), Vector2(0, -80), 1, PI * 0.5, false)

func _physics_process(_delta):
	if (target.size() > 0):
		var v = (target[0].global_position - global_position).angle()
		global_rotation = lerp(global_rotation, v, 0.5)
		#$muzzle.look_at(target[0].global_position)
		if (allowshoot == true):
			shoot()

func _on_radius_body_entered(body):
	if (body.get('hitable') && body != self && body.team != team):
		target.append(body)

func _on_radius_body_exited(body):
	if (target.has(body) && body != self):
		target.erase(body)

func _on_atkcooldown_timeout():
	allowshoot = true
	pass # Replace with function body.
